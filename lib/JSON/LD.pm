package JSON::LD;
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
use v5.14;
use warnings;
use JSON ();
use base 'Exporter';

# ABSTRACT: Expand and compact JSON-LD data

our @EXPORT_OK = qw( expand compact );
our @EXPORT    = @EXPORT_OK;




sub expand
{
    return '{}';
}

sub compact
{
    my ($in_json, $context) = @_;
    my $in = JSON::from_json( $in_json );
    return JSON::to_json( _compact( $context,
        _inverse_context( $context ), undef, $in, 1 ) );
}


sub _compact
{
    # See http://www.w3.org/TR/json-ld-api/#compaction-algorithm
    my ($active_context, $inverse_context, $active_property, $element,
        $do_compact_arrays) = @_;

    if( ref($element) eq 'SCALAR' ) { # Step 1
        return $element;
    }
    elsif( ref($element) eq 'ARRAY' ) { # Step 2
        my @results = map {
            _compact( $active_context, $inverse_context, $active_property,
                $_, $do_compact_arrays );
        } @$element;
        return scalar(@results) > 1
            ? \@results
            : $results[0];
    }
    else { # Assume hashref (JSON object) (Step 3)
        if( exists $element->{'@value'} || exists $element->{'@id'} ) {
            # Step 4
            my $compact_value = _value_compaction( $active_context,
                $inverse_context, $active_property, $element );
            if( ref($compact_value) eq 'SCALAR' ) {
                return $compact_value;
            }
        }

        # Step 5
        my $inside_reverse = ($active_property eq '@reverse') ? 1 : 0;
        my $result = {}; # Step 6

        foreach my $expanded_property (keys %$element) { # Step 7
            my $expanded_value = $element->{$expanded_property};

            if( $expanded_property eq '@id'
                || $expanded_property eq '@type'
            ) { # Step 7.1
                my $compacted_value;

                if(! ref $expanded_value ) { # Step 7.1.1
                    $compacted_value = _iri_compaction( $active_context,
                        $inverse_context, $expanded_value, {
                            vocab => ($expanded_property eq '@type'
                                ? 1 : 0)
                        },
                    );
                }
                else { # Assume @type array (Step 7.1.2)
                    $compacted_value = [
                        map {
                            _iri_compaction( $active_context, 
                                $inverse_context, $_, { vocab => 1 } );
                        } @$expanded_value
                    ];
                    $compacted_value = $compacted_value->[0]
                        if scalar(@$compacted_value) == 1;
                }

                # Step 7.1.3
                my $alias = _iri_compaction( $active_context,
                    $inverse_context, $expanded_property, { vocab => 1 } );
                $result->{alias} = $alias;
            }
        }
    }

    return {}; # Placeholder
}

sub _inverse_context
{
    my ($context) = @_;
    # TODO http://www.w3.org/TR/json-ld-api/#inverse-context-creation
    return $context;
}

sub _value_compaction
{
    my ($active_context, $inverse_context, $active_property, $value) = @_;
    # TODO http://www.w3.org/TR/json-ld-api/#value-compaction
    return $value;
}

sub _iri_compaction
{
    my ($active_context, $inverse_context, $iri, $args) = @_;
    my $is_vocab = $args->{vocab};
    # TODO http://www.w3.org/TR/json-ld-api/#iri-compaction
    return $iri;
}


1;
__END__

