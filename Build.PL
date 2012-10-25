
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Schema for data structures (specification)",
  "dist_author" => [
    "Steven Haryanto <stevenharyanto\@gmail.com>"
  ],
  "dist_name" => "Sah",
  "dist_version" => "0.9.14",
  "license" => "perl",
  "module_name" => "Sah",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "DefHash" => "v1.0.1"
  },
  "script_files" => [],
  "share_dir" => {
    "dist" => "share"
  }
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
