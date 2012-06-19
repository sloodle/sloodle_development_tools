<?php
$_SERVER = array();
$_SERVER['SERVER_NAME'] = 'gershwinklata1.avatarclassroom.com';

define('CLI_SCRIPT', 1);
require_once('config.php');
require_once($CFG->dirroot . '/backup/util/includes/backup_includes.php');
require_once($CFG->dirroot . '/backup/util/includes/restore_includes.php');


/*
Find the latest backup created with backuptest.php
}/

$backupdir = '../resources/moodledata/temp/backup';

$folder = null;
$highestmtime = 0;
foreach (glob($backupdir.'/*') as $f) {
    if (!is_dir($f)) {
        continue;
    }
    if ( !$folder || (filemtime($f) > $highestmtime) ) {
        $folder = $f;
        $highestmtime = filemtime($f);
    }
}   

$folderbits = explode('/',$folder); 
$folder = array_pop($folderbits);
echo "About to start restore from folder $folder\n";

$courseid = 3;


/*
 // Uncomment to create a course
 // Get or create category.
    $categoryname = 'Restore test';
    $categoryid = $DB->get_field( 'course_categories', 'id', array('name'=>$categoryname) );
    if (!$categoryid) {
      $categoryid = $DB->insert_record( 'course_categories', (object)array(
        'name' => $categoryname,
        'parent' => 0,
        'visible' => 0
      ));
      $DB->set_field( 'course_categories', 'path', '/' . $categoryid, array('id'=>$categoryid) );
    }

    $shortname = 'Restore ' . date( 'His' );
    $fullname = 'Restore Test ' . date( 'Y-m-d H:i:s' );

    // Create new course.
    $courseid = restore_dbops::create_new_course( $fullname, $shortname, $categoryid );
*/




// Transaction
$transaction = $DB->start_delegated_transaction();

// Create new course
//$courseid = restore_dbops::create_new_course($fullname, $shortname, $categoryid);
$userid = 2;

// Restore backup into course
$controller = new restore_controller($folder, $courseid, 
        backup::INTERACTIVE_NO, backup::MODE_SAMESITE, $userid,
        backup::TARGET_NEW_COURSE);
$controller->execute_precheck();
$controller->execute_plan();

// Commit
$transaction->allow_commit();
