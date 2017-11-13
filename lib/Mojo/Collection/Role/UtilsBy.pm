package Mojo::Collection::Role::UtilsBy;

use Role::Tiny;
use List::UtilsBy ();

our $VERSION = '0.001';

requires 'new';

my %functions_list = map { ($_ => 1) }
  qw(nsort_by rev_nsort_by rev_sort_by sort_by uniq_by weighted_shuffle_by);
my %functions_scalar = map { ($_ => 1) } qw(max_by min_by);

foreach my $func (keys %functions_list, keys %functions_scalar) {
  my $sub = List::UtilsBy->can($func) // die "Function List::UtilsBy::$func not found";
  if ($functions_list{$func}) {
    no strict 'refs';
    *$func = sub {
      my ($self, $code) = @_;
      return ref($self)->new($sub->($code, @$self));
    };
  } elsif ($functions_scalar{$func}) {
    no strict 'refs';
    *$func = sub {
      my ($self, $code) = @_;
      return scalar $sub->($code, @$self);
    };
  }
}

sub bundle_by {
  my ($self, $code, $n) = @_;
  return ref($self)->new(&List::UtilsBy::bundle_by($code, $n, @$self));
}

sub count_by {
  my ($self, $code) = @_;
  return +{ &List::UtilsBy::count_by($code, @$self) };
}

sub extract_by {
  my ($self, $code) = @_;
  return ref($self)->new(&List::UtilsBy::extract_by($code, \@$self));
}

sub extract_first_by {
  my ($self, $code) = @_;
  return scalar &List::UtilsBy::extract_first_by($code, \@$self);
}

sub partition_by {
  my ($self, $code) = @_;
  my $class = ref $self;
  return +{ List::UtilsBy::bundle_by { ($_[0] => $class->new(@{$_[1]})) } 2,
    &List::UtilsBy::partition_by($code, @$self) };
}

1;

=head1 NAME

Mojo::Collection::Role::UtilsBy - List::UtilsBy methods for Mojo::Collection

=head1 SYNOPSIS

  use Mojo::Collection 'c';
  my $c = c(1..12)->with_roles('+UtilsBy');
  say 'Reverse lexical order: ', $c->rev_sort_by(sub { $_ })->join(',');
  
  use List::Util 'product';
  say "Product of 3 elements: $_" for $c->bundle_by(sub { product(@_) }, 3)->each;
  
  my $partitions = $c->partition_by(sub { $_ % 4 });
  # { 0 => c(4,8,12), 1 => c(1,5,9), 2 => c(2,6,10), 3 => c(3,7,11) }
  
  my $evens = $c->extract_by(sub { $_ % 2 == 0 }); # $c now contains only odd numbers

=head1 DESCRIPTION

A role to augment L<Mojo::Collection> with methods that call functions from
L<List::UtilsBy>. With the exception of L</"bundle_by">, all passed callbacks
will be called with both C<$_> and C<$_[0]> set to the current element in the
iteration.

=head1 METHODS

L<Mojo::Collection::Role::UtilsBy> composes the following methods.

=head2 bundle_by

  my $bundled_collection = $c->bundle_by(sub { c(@_) }, $n);

Return a new collection containing the results from the passed function, given
input elements in bundles of (up to) C<$n> at a time, using
L<List::UtilsBy/"bundle_by">. The passed function will receive each bundle of
inputs in C<@_>, and will receive less than C<$n> if not enough elements remain.

=head2 count_by

  my $counts = $c->count_by(sub { $_->name });

Return a hashref where the values are the number of times each key was returned
from the passed function, using L<List::UtilsBy/"count_by">.

=head2 extract_by

  my $extracted_collection = $c->extract_by(sub { $_->num > 5 });

Remove elements from the collection that return true from the passed function
using L<List::UtilsBy/"extract_by">, and return a new collection containing the
removed elements.

=head2 extract_first_by

  my $extracted_element = $c->extract_first_by(sub { $_->name eq 'Fred' });

Remove and return the first element from the collection that returns true from
the passed function using L<List::UtilsBy/"extract_first_by">.

=head2 max_by

  my $max_element = $c->max_by(sub { $_->num });

Return the element from the collection that returns the numerically largest
result from the passed function with L<List::UtilsBy/"max_by">.

=head2 min_by

  my $min_element = $c->min_by(sub { $_->num });

Return the element from the collection that returns the numerically smallest
result from the passed function with L<List::UtilsBy/"min_by">.

=head2 nsort_by

  my $sorted_collection = $c->nsort_by(sub { $_->num });

Return a new collection containing the elements sorted numerically by the
results from the passed function, using L<List::UtilsBy/"nsort_by">.

=head2 partition_by

  my $collections = $c->partition_by(sub { $_->name });

Return a hashref where the values are collections of the elements that returned
that key from the passed function, using L<List::UtilsBy/"partition_by">.

=head2 rev_nsort_by

  my $sorted_collection = $c->rev_nsort_by(sub { $_->num });

Return a new collection containing the elements sorted numerically in reverse
by the results from the passed function, using L<List::UtilsBy/"rev_nsort_by">.

=head2 rev_sort_by

  my $sorted_collection = $c->rev_sort_by(sub { $_->name });

Return a new collection containing the elements sorted lexically in reverse
by the results from the passed function, using L<List::UtilsBy/"rev_sort_by">.

=head2 sort_by

  my $sorted_collection = $c->sort_by(sub { $_->name });

Return a new collection containing the elements sorted lexically by the results
from the passed function, using L<List::UtilsBy/"sort_by">.

=head2 uniq_by

  my $uniq_collection = $c->uniq_by(sub { $_->name });

Return a new collection containing the elements that return stringwise unique
values from the passed function, using L<List::UtilsBy/"uniq_by">.

=head2 weighted_shuffle_by

  my $shuffled_collection = $c->weighted_shuffle_by(sub { $_->num });

Return a new collection containing the elements shuffled with weighting
according to the results from the passed function, using
L<List::UtilsBy/"weighted_shuffle_by">.

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book <dbook@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2017 by Dan Book.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=head1 SEE ALSO

L<Mojo::Collection>, L<List::UtilsBy>
