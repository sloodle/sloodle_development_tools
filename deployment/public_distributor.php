<?php
/**
*
* Script for exposing a distributor object to public web access.
* This is intended for use only on the servers of people who want to run a distributor for Sloodle objects.
*
* ( However, functionality that accesses it to send the avatar of their choice suitable objects 
* for their Sloodle install, once written, is intended to go into the regular Sloodle distribution. )
* 
* It should be installed under mod/sloodle, ie. in the same directory as sl_config.php
*
* Parts of this script require manual configuration. (See below)
*
* Distributor functionality is based on that used in view/distributor.php
* 
* WARNING: 
*   As of 2009-12-18, this script does not respect course permissions or distributor public / group settings.
*   Ideally, it should probably ignore course permissions but only run if the distributor is public.
*   Since it is anticipated that only a few people will want to run it on their servers, it should probably either:
*      a) Not be included in the standard Sloodle distribution, or
*      b) Included, but with an "exit" right at the start so that it only runs if manually altered.
*   For now, we'll check it into tools/distribution/, and install it manually where we need it.
*
* Usage examples: 
* 
* Send the object "thing" in the distributor with ID 14 to the user with the key 746ad236-d28d-4aab-93de-1e09a076c5f3
* http://dev1.socialminds.jp/mod/sloodle/public_distributor.php?id=14&object=thing&user=746ad236-d28d-4aab-93de-1e09a076c5f3
*
* Send the object "thing" in the distributor with ID 14 to the user with the name Edmund Earp
* http://dev1.socialminds.jp/mod/sloodle/public_distributor.php?id=14&object=thing&av_name=Edmund%20Earp
*
* @package sloodle
* @copyright Copyright (c) 2008 to 2010 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributor Edmund Edgar, KK Social Minds
* @contributor Peter R. Bloomfield
*/

//
// Manual configuration begins
//

// List the name2key services you want to use here.
$name2keyServices = array(
	'http://vision-tech.org/name2key/search.php?name=' => 'LookupBasedName2KeyService',
	'http://kdc.ethernia.net/sys/name2key.php' => 'GenericName2KeyService'
);

/* 
If you want to receive alerts when this service is about to break, put your address and the failure threshold here.
Probably best to keep at least one provider in reserve, eg. if you have 3 providers, have it warn you when the first 2 go down.
*/
$warningMailAddressesAndThresholds = array(
	'you@example.com' => 2
);

//
// Manual configuration ends
//

/** SLOODLE and Moodle configuration */
require_once('sl_config.php');
/** General SLOODLE library functionality */
require_once(SLOODLE_LIBROOT.'/general.php');

// Get the distributor course module ID from a URL parameter.
// NB If it turns out that it's hard to keep these stable over time,
// ...it may be better to hard-code the distributor ID here
// ...or to remove it and wrap this script in another one, 
// ...eg. distributor_stable_1_0.php would set $id for the 1.0 stable distributor, then include this file
$id = required_param('id', PARAM_INT);
if (!$cm = get_coursemodule_from_id('sloodle', $id)) error('Course module ID was incorrect.');

// Ignore the course data. If there's a public distributor, we'll let anyone use it.
// The following was in the original view/distributor.php
/*
// Fetch the course data
if (!$this->course = get_record('course', 'id', $this->cm->course)) error('Failed to retrieve course.');
$this->sloodle_course = new SloodleCourse();
if (!$this->sloodle_course->load($this->course)) error(get_string('failedcourseload', 'sloodle'));
*/

// Fetch the SLOODLE instance itself
if (!$sloodle = sloodle_get_record('sloodle', 'id', $cm->instance)) error('Failed to find SLOODLE module instance');

if (!$distributor = sloodle_get_record('sloodle_distributor', 'sloodleid', $sloodle->id)) error('Failed to get SLOODLE Distributor data.');

$entries = sloodle_get_records('sloodle_distributor_entry', 'distributorid', $distributor->id, 'name');

// If the query failed, then assume there were simply no items available
if (!is_array($entries)) $entries = array();
$numitems = count($entries);

if (isset($_REQUEST['user'])) $send_user = $_REQUEST['user'];
if (isset($_REQUEST['object'])) $send_object = $_REQUEST['object'];
if (isset($_REQUEST['av_name'])) $av_name = $_REQUEST['av_name'];

// If we don't have the avatar key but we do have their name, try to look up the key based on the name
if ( empty($send_user) && ( !empty($av_name) ) ) {

	$atLeastOneServiceSucceeded = false;

	// Try to do a lookup on a name2key service
	$failedServices = array();
	foreach( $name2keyServices as $url => $cls ) {

		$service = new $cls();
		$service->setServiceBaseURL( $url );
		$service->setAvatarName( $av_name );

		if ( $service->lookup() ) {
			$atLeastOneServiceSucceeded = true;
			if ( $service->foundKey() ) {
				$send_user = $service->uuid();
				break;
			} else if ( $service->isExhaustive() ) {
				// The service confirmed that they key doesn't exist, so we won't trouble the other services
				break;
			}						
			// If we couldn't find the key but the service may just not know about it, stay in the loop and try the next one
		} else {
			// The service failed to respond or its response didn't make sense, so keep going and try the next one
			// We'll make a note of the fact that it failed so that we can tell the administrator if too many services are broken.
			$failedServices[] = $service->queryURL();
		}

	}

	if ( ( count($failedServices) > 0 ) && ( count($warningMailAddressesAndThresholds) > 0 ) ) {

		foreach( $warningMailAddressesAndThresholds as $emailaddress => $threshold ) {
			if ( count($failedServices) >= $threshold ) {
				mail( $emailaddress, 'Sloodle name2key lookups failing', "The following lookups failed: \n".join("\n",$failedServices)."\n\nThis is above your warning threshold of $threshold.\n" );
			}	
		}

	}

	if ( !$atLeastOneServiceSucceeded ) {
		print 'sloodleobjectdistributor:allkey2nameservicesfailed'."\n";
		exit;
	}

	if ( empty( $send_user ) ) {
		print 'sloodleobjectdistributor:keyfornamenotfound'."\n";
		exit;
	}
	
}

if (empty($distributor->channel)) {
	print 'sloodleobjectdistributor:nochannel'."\n";
	exit;
}

// If the user and object parameters are set, then try to send an object
if (!empty($send_user) && !empty($send_object)) {

	// Convert the HTML entities back again
	$send_object = htmlentities(stripslashes($send_object));

	// Construct and send the request
	$request = "1|OK\\nSENDOBJECT|$send_user|$send_object";
	$ok = sloodle_send_xmlrpc_message($distributor->channel, 0, $request);

	// What was the result?
	if ($ok) {
		print 'sloodleobjectdistributor:successful'."\n";
	} else {
		print 'sloodleobjectdistributor:failed'."\n";
	}
	print 'Object'.': '.$send_object."\n";
	print 'uuid'.': '.$send_user."\n";
	exit;

}
 
if ($numitems < 1) {
	print 'sloodleobjectdistributor:noobjects'."\n";
	exit;
}

foreach ($entries as $e) {
	print $e->name."\n";
}

/*
	The following is based on how http://name2key.alpha-fox.com works.
	You just append /?name= to the URL, followed by the avatar name...
	... and it returns either the name or the null key 00000000-0000-0000-0000-000000000000
	This seems pretty standard - hopefully any other service we will need to use will work this way too.
	If they don't, make a new class inheriting from GenericName2KeyService and override whatever they do differently.	
*/
class GenericName2KeyService {
	
	var $_av_name = null;
	var $_base_url = null;

	var $_result = '';

	function setServiceBaseURL( $url ) {
		// eg http://name2key.alpha-fox.com
		$this->_base_url = $url;
	}

	function setAvatarName( $av_name) {
		$this->_av_name = $av_name;
	}

	function queryURL() {
		return $this->_base_url.'/?name='.urlencode($this->_av_name);
	}

	// Do a lookup, and return true if the lookup goes as expected.
	// NB This will return true even if we couldn't find the key...
	// ... which we'll consider a successful lookup that successfully told us that the service didn't know an avatar of that name.
	// Use foundKey() to find out whether the key was actually there or not.
	function lookup() {

		$ch = curl_init();
		curl_setopt( $ch, CURLOPT_URL, $this->queryURL() );
		curl_setopt( $ch, CURLOPT_RETURNTRANSFER, 1 );
		curl_setopt( $ch, CURLOPT_TIMEOUT,$this->timeout() ); 
		$result = curl_exec($ch);
		if ( $result ) {	
			$this->_result = $this->cleanResult( $result );
			return $this->isResultExpectedFormat( $result );
		}
		return false;	

	}

	// clean the result after we get it back
	// if there's a new line or something, strip it.
	function cleanResult( $result ) {
		$result = preg_replace('/\n/', '', $result);
		$result = preg_replace('/\r/', '', $result);
		return $result;
	}

	// We should get either a key or a null key.
	// Anything else - say an error message - will be considered a failure.
	function isResultExpectedFormat( $result ) {
		return ( preg_match('/^........-....-....-....-............$/', $result ) ); 
	}

	// Return true if we found a key
	function foundKey() {
		return ( ( $this->_result != '' ) && ( $this->_result != '00000000-0000-0000-0000-000000000000' ) ); 	
	}

	function uuid() {
		if ( $this->foundKey() ) {
			return $this->_result;
		} else {
			return null;
		}
	}

	// Return true if the service claims to be able to reach all the keys on the grid.
	// Lookup-based services should be able to do this, while database-based services should not.
	function isExhaustive() {
		return false;
	}

	// timeout in seconds after which we should give up waiting for a service.
	// bear in mind that we may try several services, while the user's waiting, so we shouldn't make this too long.
	function timeout() {
		return 10;
	}

}

class LookupBasedName2KeyService extends GenericName2KeyService {

	function isExhaustive() {
		return true;
	}

}

?>
