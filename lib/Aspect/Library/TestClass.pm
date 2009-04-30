package Aspect::Library::TestClass;

use strict;
use warnings;
use Carp;
use Test::Class;
use Aspect;

our $VERSION = '0.15';

use base 'Aspect::Modular';

sub Test::Class::make_subject { shift->subject_class->new(@_) }

sub get_advice {
	my ($self, $pointcut) = @_;
	before {
		my $context = shift;
		my $self    = $context->self; # the Test::Class object
		return unless is_test_method_with_subject($context);
		my (@params) = $self->subject_params if $self->can('subject_params');
		my $subject = $self->make_subject(@params);
		$self->init_subject_state($subject) if $self->can('init_subject_state');
		$context->append_param($subject);
	} call qr/::[a-z][^:]*$/ & $pointcut;
}

# true if we are in a test class, in a test method, and we can get a
# subject_class from the test class
# would be nice if we could somehow check for existence of test attribute
# on method
sub is_test_method_with_subject {
	my $context = shift;
	my $self    = $context->self; # the Test::Class object
	my @method  = ($context->package_name, $context->short_sub_name);
	return
		UNIVERSAL::isa($self, 'Test::Class') &&
		$self->_method_info(@method) &&
		$self->can('subject_class');
}

1;

__END__

=pod

=head1 NAME

Aspect::Library::TestClass - give Test::Class test methods an IUT
(implementation under test)

=head1 SYNOPSIS

  # append IUT to params of all test methods in matching packages
  # place this in your test script
  aspect TestClass => call qr/::tests::/;

=head1 SUPER

L<Aspect::Modular>

=head1 DESCRIPTION

Frequently my C<Test::Class> test methods look like this:

  sub some_test: Test {
     my $self = shift;
     my $subject = IUT->new;
     # send $subject messages and verify expected results
     ...
  }

After installing this aspect, they look like this:

  sub some_test: Test {
     my ($self, $subject) = @_;
     # send $subject messages and verify expected results
     ...
  }

In the test class you must add one I<template method> to provide the
class of the IUT:

  sub subject_class { 'MyApp::Person' }

=head1 REQUIRES

Only works with C<Test::Class> above version C<0.06_05>.
  
=head1 SEE ALSO

See the L<Aspect|::Aspect> pods for a guide to the Aspect module.

C<XUL-Node> tests use this aspect extensively.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit <http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see <http://www.perl.com/CPAN/authors/id/M/MA/MARCEL/>.

=head1 AUTHORS

Marcel GrE<uuml>nauer, C<< <marcel@cpan.org> >>

Ran Eilam C<< <eilara@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2001 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
