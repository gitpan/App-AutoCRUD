use strict;
use warnings;
use LWP::UserAgent;

#======================================================================
# data: sample databases
#======================================================================
my $chinook_zip = "ChinookDatabase1.4_Sqlite.zip";
my %databases = (

  sakila  => {
    source => "http://sakila-sample-database-ports.googlecode.com/svn/trunk/ sakila-sample-database-ports/sqlite-sakila-db/sqlite-sakila.sq",
    dest   => "Sakila/sakila.sqlite",
  },

  chinook => {
    source => "http://download-codeplex.sec.s-msft.com//Download/Release?ProjectName=chinookdatabase&DownloadId=557773&FileTime=129989782797830000&Build=20919",
    dest   => $chinook_zip,
    hook   => sub {
      use Archive::Zip;
      my $member  = "Chinook_Sqlite_AutoIncrementPKs.sqlite";
      my $zip = Archive::Zip->new($chinook_zip);
      $zip->extractMember($member, "Chinook/$member");
      undef $zip;
      # unlink $chinook_zip;
    },
  },

  foo => {
    source => "https://github.com/IntelliTree/RA-ChinookDemo/blob/master/chinook.db?raw=true",
    dest => "foo.db",
  },



 );


#======================================================================
# download
#======================================================================

# choose databases to download
my @to_download = @ARGV ? @ARGV : keys %databases;


my $ua = LWP::UserAgent->new;

# download each database
foreach my $db_name (@to_download) {
  my $db = $databases{$db_name}
    or die "unknown database : $db_name";
  print STDERR "downloading $db_name to $db->{dest} ...";
  my $resp = $ua->mirror($db->{source}, $db->{dest});
  if ($resp->is_success) {
    print STDERR " running hook .. " and $db->{hook}->() if $db->{hook};
    print STDERR "done\n";
  }
  else {
    print STDERR $resp->status_line, "\n";
  }
}



