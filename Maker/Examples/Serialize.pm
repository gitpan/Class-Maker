our $VERSION = '0.01';

use Data::DumpXML qw(dump_xml);

Class::Maker::class Serialize::XML,
{
	version => $VERSION,

	persistance =>
	{
		abstract => 1,
	},
};

=head1 Method B<>

=cut

sub Serialize::XML::to_xml : method
{
	my $this = shift;

return $_=dump_xml( $this );
}

sub Serialize::XML::dtd : method
{
	local $/ = '';

return $_=<DATA>;
}

sub Serialize::XML::dtd_and_xml : method
{
	my $this = shift;

	my $tag = quotemeta q{<!DOCTYPE data SYSTEM "dumpxml.dtd">};

	my $dtd = $this->dtd();

	$_ = $this->to_xml();

	s/$tag/$dtd/;

return $_;
}

1;

__DATA__

<!DOCTYPE data [
 <!ENTITY % scalar "undef | str | ref | alias">
 <!ELEMENT data (%scalar;)*>
 <!ELEMENT undef EMPTY>
 <!ELEMENT str (#PCDATA)>
 <!ELEMENT ref (%scalar; | array | hash | glob | code)>
 <!ELEMENT alias EMPTY>
 <!ELEMENT array (%scalar;)*>
 <!ELEMENT hash  (key, (%scalar;))*>
 <!ELEMENT key (#PCDATA)>
 <!ELEMENT glob EMPTY>
 <!ELEMENT code EMPTY>
 <!ENTITY % stdattlist 'id       ID             #IMPLIED
                        class    CDATA          #IMPLIED'>
 <!ENTITY % encoding   'encoding (plain|base64) "plain"'>
 <!ATTLIST undef %stdattlist;>
 <!ATTLIST ref %stdattlist;>
 <!ATTLIST undef %stdattlist;>
 <!ATTLIST array %stdattlist;>
 <!ATTLIST hash %stdattlist;>
 <!ATTLIST glob %stdattlist;>
 <!ATTLIST code %stdattlist;>
 <!ATTLIST str %stdattlist; %encoding;>
 <!ATTLIST key %encoding;>
 <!ATTLIST alias ref IDREF #IMPLIED>
]>

__END__

or with another library

# Convert Perl code to XML
use XML::Dumper;
my $dump = new XML::Dumper;
$data = [
         {
           first => 'Jonathan',
           last => 'Eisenzopf',
           email => 'eisen@pobox.com'
         },
         {
           first => 'Larry',
           last => 'Wall',
           email => 'larry@wall.org'
         }
        ];
$xml =  $dump->pl2xml($perl);

# Convert XML to Perl code
use XML::Dumper;
my $dump = new XML::Dumper;

# some XML
my $xml = <<XML;
perldata>
<scalar>foo</scalar>
/perldata>
XML

# load Perl data structure from dumped XML
$data = $dump->xml2pl($Tree);
