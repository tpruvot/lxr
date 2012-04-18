# -*- tab-width: 4; cperl-indent-level: 4 -*- ###############################################
#
# $Id: Lang.pm,v 1.44 2012/04/17 10:57:59 ajlittoz Exp $

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

package LXR::Lang;

$CVSID = '$Id: Lang.pm,v 1.44 2012/04/17 10:57:59 ajlittoz Exp $ ';

use strict;
use LXR::Common;

sub new {
	my ($self, $pathname, $releaseid, @itag) = @_;
	my ($lang, $type);

	foreach $type (values %{ $config->filetype }) {
		if ($pathname =~ /$$type[1]/) {
			eval "require $$type[2]";
			die "Unable to load $$type[2] Lang class, $@" if $@;
			my $create = $$type[2] . '->new($pathname, $releaseid, $$type[0])';
			$lang = eval($create);
			die "Unable to create $$type[2] Lang object, $@" unless defined $lang;
			last;
		}
	}

	if (!defined $lang) {

		# Try to see if it's a #! script or an emacs mode-tagged file
		my $fh = $files->getfilehandle($pathname, $releaseid);
		return undef if !defined $fh;
		my $line = $fh->getline;
		($line =~ /^\#!\s*(\S+)/s)
		|| ($line =~ /^.*-[*]-.*?[ \t;]mode:[ \t]*(\w+).*-[*]-/);

		my $shebang  = $1;
		my %filetype = %{ $config->filetype };
		my %inter    = %{ $config->interpreters };

		foreach my $patt (keys %inter) {
			if ($shebang =~ /$patt$/) {
				eval "require $filetype{$inter{$patt}}[2]";
				die "Unable to load $filetype{$inter{$patt}}[2] Lang class, $@" if $@;
				my $create = $filetype{ $inter{$patt} }[2]
				  . '->new($pathname, $releaseid, $filetype{$inter{$patt}}[0])';
				$lang = eval($create);
				last if defined $lang;
				die "Unable to create $filetype{$inter{$patt}}[2] Lang object, $@";
			}
		}
	}

	# No match for this file
	return undef if !defined $lang;

	$$lang{'itag'} = \@itag if $lang;

	return $lang;
}

sub processinclude {
	my ($self, $frag, $dir) = @_;
	warn  __PACKAGE__."::processinclude not implemented. Parameters @_";
	return;
}

sub multilinetwist {
	my ($frag, $css) = @_;
	$$frag = "<span class=\"$css\">$$frag</span>";
	$$frag =~ s!\n!</span>\n<span class="$css">!g;
	$$frag =~ s!<span class="comment"></span>$!! ; #remove excess marking
}

sub processcomment {
	my ($self, $frag) = @_;

	multilinetwist($frag, 'comment');
}

sub processstring {
	my ($self, $frag) = @_;

	multilinetwist($frag, 'string');
}

#
# Stub implementations of this interface
#

sub processcode {
	my ($self, $code) = @_;
	warn  __PACKAGE__."::processcode not implemented. Parameters @_";
	return;
}

sub processreserved {
	my ($self, $frag) = @_;
	warn  __PACKAGE__."::processreserved not implemented. Parameters @_";
	return;
}

sub referencefile {
	my ($self, $name, $path, $fileid, $index, $config) = @_;
	warn  __PACKAGE__."::referencefile not implemented. Parameters @_";
	return;
}

sub language {
	my ($self) = @_;
	my $languageName;
	warn  __PACKAGE__."::language not implemented. Parameters @_";
	return $languageName;
}

1;
