<?php
$_SERVER = array();
$_SERVER['SERVER_NAME'] = 'gershwinklata1.avatarclassroom.com';

define('CLI_SCRIPT', 1);
require_once('config.php');
require_once($CFG->dirroot . '/backup/util/includes/backup_includes.php');
require_once($CFG->dirroot . '/backup/util/includes/restore_includes.php');

$backup_types = array(
    'course' => backup::TYPE_1COURSE,
    'activity' => backup::TYPE_1ACTIVITY
);

if (count($argv) < 2) {
    print "Usage: ".$argv[0]." <user> <type> <course> [<backup_folder>]\n";
    exit;
}

$user_doing_the_backup   = intval($argv[1]); //2; // Set this to the id of your admin accouun

$backup_type_arg = $argv[2];

if (!isset($backup_types[$backup_type_arg])) {
    print "Backup type $backup_type_arg not supported.\n";
    exit;
}

//$course_module_to_backup = 2; // Set this to one existing choice cmid in your dev site
$courseid = intval($argv[3]); //27; //3; // Set this to one existing choice cmid in your dev site

if (!$user_doing_the_backup) {
    print "Parameters wrong\n";
    exit;
}

if (!$courseid && ($backup_type == backup::TYPE_1ACTIVITY) ) {
    print "For a backup of type $backup_type_arg, you need to specify a course ID to restore to.\n";
    exit;
}

$backupdir = '../resources/moodledata/temp/backup';

if (isset($argv[4])) {

    $folder = $argv[4];

} else {
     
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

}

echo "About to start restore from backup folder $folder\n";

if (!$courseid) {
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

} 

// Transaction
$transaction = $DB->start_delegated_transaction();

// Create new course
//$courseid = restore_dbops::create_new_course($fullname, $shortname, $categoryid);

// Restore backup into course
$controller = new restore_controller($folder, $courseid, 
        backup::INTERACTIVE_NO, backup::MODE_SAMESITE, $user_doing_the_backup,
        backup::TARGET_NEW_COURSE);
$controller->execute_precheck();
$controller->execute_plan();

// Commit
$transaction->allow_commit();
