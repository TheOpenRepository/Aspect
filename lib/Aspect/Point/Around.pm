package Aspect::Point::Around;
=pod

=head1 NAME

Aspect::Point - The Join Point context for "around" advice code

=head1 SYNOPSIS

=head1 METHODS

=cut

use strict;
use warnings;
use Aspect::Point ();

our $VERSION = '0.98';
our @ISA     = 'Aspect::Point';

use constant type => 'around';

sub original {
	$_[0]->{original};
}

sub proceed {
	my $self = shift;

	return $self->return_value(
		Sub::Uplevel::uplevel(
			2,
			$self->{original},
			@{$self->{args}},
		)
	) if $self->{wantarray};

	return $self->return_value(
		scalar Sub::Uplevel::uplevel(
			2,
			$self->{original},
			@{$self->{args}},
		)
	) if defined $self->{wantarray};

	return Sub::Uplevel::uplevel(
		2,
		$self->{original},
		@{$self->{args}},
	);
}

BEGIN {
	*run_original = *proceed;
}





######################################################################
# Optional XS Acceleration

BEGIN {
	local $@;
	eval <<'END_PERL';
use Class::XSAccessor 1.08 {
	replace => 1,
	getters => {
		'original'   => 'original',
	},
};
END_PERL
}

1;

=pod

=head1 AUTHORS

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

Marcel GrE<uuml>nauer E<lt>marcel@cpan.orgE<gt>

Ran Eilam E<lt>eilara@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2001 by Marcel GrE<uuml>nauer

Some parts copyright 2009 - 2011 Adam Kennedy.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
