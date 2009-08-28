
# (c) 2008 by Murat Uenalan. All rights reserved. Note: This program is
# free software; you can redistribute it and/or modify it under the same
# terms as perl itself
package Class::Maker::Type;

sub new
{
	my $this = ref( $_[0] ) || $_[0];

return bless { tieobj => 'Tie::HASH' }, $this;
}

package Class::Maker::Types;

{
	package Class::Maker::Types::int;

	sub get
	{
	}

	sub set
	{
	}
}

{
	package Class::Maker::Types::string;

	sub get
	{
	}

	sub set
	{
	}
}

1;
