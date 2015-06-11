# Copyright (c) 2015  Timm Murray
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, 
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright 
#       notice, this list of conditions and the following disclaimer in the 
#       documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
use Test::More tests => 46;
use v5.14;
use JSON::LD 'compact';
use JSON 'from_json';
use Test::Differences;
use File::Slurp 'read_file';

my %TODO_TESTS = map {
    $_ => 1,
} 1 .. 46;

my %OPTIONS = (
    44 => {
        compactArrays => 0,
    },
);


my $i = 0;
foreach ( glob( 't_data/flatten-*-in.jsonld' ) ) {
    my ($in, $out, $context) = ($_) x 3;
    $out     =~ s/-in\./-out\./;
    $context =~ s/-in\./-context\./;
    $context = undef if ! -e $context;
    my %options = exists $OPTIONS{$i}
        ? %{ $OPTIONS{$i} }
        : ();

    $i++;
    note( "Test $i In: $in" );
    note( "Test $i Context: $context" );
    note( "Test $i Out: $out" );

    local $TODO = exists $TODO_TESTS{$i}
        ? "Test $_ not yet implemented"
        : undef;
    my $got_out      = from_json( compact( $in, $context, \%options ) );
    my $expected_out = from_json( read_file( $out ) );
    eq_or_diff $got_out, $expected_out, "Test $in";
}
