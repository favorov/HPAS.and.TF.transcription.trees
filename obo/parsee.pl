#/usr/bin/perl -w

use List::MoreUtils qw/ uniq /;

use strict;

my $fname="FANTOM5v6_af.obo";
my $idnamesfile="idnames";
my $isarelationsfile="isarelations";
my $tissuenamesfile="tissuenames";

my %isas;
#for each id, we want to put all its parent symbols

my %id_names;
#$id_names{$id} is its name, very easy

my $state="out";

open IN,$fname;


my $id;
my @isa_loc=();
my $name;

while(<IN>)
{
	if (/^\[Term\]$/)
	{
		if ($state eq "out")
		{
			$state="in";
			next;
		}
		else 
		{
			stop("Double [term]\n");
		}
	}
	if (/^\s*$/)
	{
		if ($state eq "in")
		{
			$state="out";
			$id_names{$id}=$name;
			my $listref=$isas{$id}=[];
			push (@$listref,@isa_loc);
			splice(@isa_loc);
		}
		next;
	}
	if ($state eq "in")
	{
		if (/^id:\s*(\S+)\s*$/)
		{
			$id=$1;
		}
		if (/^name:\s*(.+)\s*$/)
		{
			$name=$1;
		}
		if (/^is_a:\s*(\S+)\s*!.+$/)
		{
			push @isa_loc,$1;
		}
	}
	else
	{
		next;
	}
}

close IN;

#here, we have all the names for ids in %id_names
#and the explicit parents in %isas

my $did_we_grow;

my @isakeys=sort keys %isas;

# we want %isas for each of id to have all the parents, not only
#eplicitely showed as is_a, also is_a(is_a), is_a(is_a(is_a)), etc
do 
{
	$did_we_grow=0;
	for $id (@isakeys)
	{
		my $listref=$isas{$id};
		my $len=scalar @$listref;
		for my $upper_id (@$listref)
		{
			if (defined ($isas{$upper_id}))
			{
				my $addlistref=$isas{$upper_id};
				push (@$listref, @$addlistref);
				@$listref=uniq @$listref;
			}
		}
		$did_we_grow=1 if ((scalar @$listref) > $len);
	}
} while ($did_we_grow);

#we grew %isas recursively, it does not grow any more
#now, let's trim it: we need only tissues (FF:\w+-\w+)

my $tissue_pattern='FF:\w+-\w+';

my @tissue_ids;

for $id (@isakeys)
{
	push @tissue_ids, $id if ($id=~m/$tissue_pattern/);
}

#ok. Now we have sorted list of tissue ids. Now, let's collect used names

my @tissue_upstream_ids=();

for $id (@tissue_ids)
{
	push (@tissue_upstream_ids,@{$isas{$id}});
	@tissue_upstream_ids=uniq @tissue_upstream_ids;
}

@tissue_upstream_ids=sort @tissue_upstream_ids;

open OUT,">$isarelationsfile.txt";
#now, the main trick. We want the relations to be a contingency table
#here, we stronly rely on two facts: the IDs are unique
#the arrays are sorted....
#so, first - header!

#print OUT " \t",join("\t",@tissue_upstream_ids);

print scalar @tissue_upstream_ids;

print OUT join("\t",@tissue_upstream_ids);
print OUT "\n";

for $id (@tissue_ids)
{
	print OUT $id;

	my @tissue_is=sort @{$isas{$id}};

	#print OUT join("\t",@$tissue_is);
	#print OUT "\n";


	my $subset_ind=0;

	for (my $setind=0;$setind<scalar @tissue_upstream_ids;$setind++)
	{
		if (
			($subset_ind<scalar @tissue_is) 
			and 
			(@tissue_upstream_ids[$setind] eq $tissue_is[$subset_ind])
		)
		{
			print OUT "\t1";
			$subset_ind++;
			next;
		}
		print OUT "\t0";
	}
	print OUT "\n";
}
close OUT;

open OUT,">$idnamesfile.txt";
for $id (@tissue_upstream_ids) #we show only useful names
{
	print OUT $id,"\t",$id_names{$id},"\n";
}
close OUT;

open OUT,">$tissuenamesfile.txt";
for $id (@tissue_ids) #we show only useful names
{
	print OUT $id,"\t",$id_names{$id},"\n";
}
close OUT;


