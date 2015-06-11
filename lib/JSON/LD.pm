package JSON::LD;

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
    return '{}';
}


1;
__END__

