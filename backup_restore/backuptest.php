<?php
$_SERVER = array();
$_SERVER['SERVER_NAME'] = 'gershwinklata1.avatarclassroom.com';
 
define('CLI_SCRIPT', 1);
require_once('config.php');
require_once($CFG->dirroot . '/backup/util/includes/backup_includes.php');

$backup_types = array(
    'course' => backup::TYPE_1COURSE,
    'activity' => backup::TYPE_1ACTIVITY
);

if (count($argv) < 3) {
    print "Usage: ".$argv[0]." <user> <type> <course_or_activity_id> [<file_to_show_afterwards>]\n";
    exit;
}

$user_doing_the_backup   = intval($argv[1]); //2; // Set this to the id of your admin accouun

$backup_type_arg = $argv[2];

if (!isset($backup_types[$backup_type_arg])) {
    print "Backup type $backup_type_arg not supported.\n";
    exit;
}

$backup_type = $backup_types[$backup_type_arg];

//$course_module_to_backup = 2; // Set this to one existing choice cmid in your dev site
$course_module_to_backup = intval($argv[3]); //27; //3; // Set this to one existing choice cmid in your dev site

if (!$course_module_to_backup || !$user_doing_the_backup) {
    print "Parameters wrong\n";
    exit;
}

 
$bc = new backup_controller($backup_type, $course_module_to_backup, backup::FORMAT_MOODLE, backup::INTERACTIVE_NO, backup::MODE_GENERAL, $user_doing_the_backup);
//$bc = new backup_controller(backup::TYPE_1COURSE, $course_module_to_backup, backup::FORMAT_MOODLE, backup::INTERACTIVE_NO, backup::MODE_GENERAL, $user_doing_the_backup);

$bc->execute_plan();


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

//$folderbits = explode('/',$folder);
//$folder = array_pop($folderbits);

print "\n\n";
print "Most recent backup folder, probably the one I created: \n";
print "$folder\n";

if (isset($argv[4])) {
    if ($cmd = $argv[4]) {
        echo `cat $folder/$argv[4]`;
    }
}
