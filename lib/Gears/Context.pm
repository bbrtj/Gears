package Gears::Context;

use v5.40;
use Mooish::Base -standard;

use Devel::StrictMode;

has param 'app' => (
	(STRICT ? (isa => InstanceOf ['Gears::App']) : ()),
);

