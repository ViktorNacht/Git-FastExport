use Test::More;
use Cwd;
use Git;
use Git::FastExport;
use File::Temp qw( tempdir );

# setup a temporary git repo
my $dir = tempdir( CLEANUP => 1 );

# alas, this can't be done with Git.pm
my $cwd = getcwd;
chdir $dir;
`git init`;
chdir $cwd;

my $git = Git->repository( Directory => $dir );

my @tests = (

    # desc, args
    [''],
    [ "Git->new( Directory => $dir )", $git ],
    [ $dir, $dir ],
);

my @fails = (

    # desc, error, regex, args
    [ q('zlonk'), qr/^zlonk is not a valid git repository/, 'zlonk' ],
    [ q('zlonk'), qr/^Zlonk=HASH\S+ is not a Git object/, bless {}, 'Zlonk' ],

    # [q(''), ''], # should fail (Git.pm issue)
    # [q(0), 0],   # should fail (Git.pm issue)
);

plan tests => 3 * @tests + 3 * @fails;

for my $t (@tests) {
    my ( $desc, @args ) = @$t;
    my $export;
    ok( eval { $export = Git::FastExport->new(@args); 1 },
        "Git::FastExport->new($desc)" );
    is( $@, '', "No error calling Git::FastExport->new($desc)" );
    isa_ok( $export, 'Git::FastExport' );

}

# some failure tests
for my $t (@fails) {
    my ( $desc, $regex, @args ) = @$t;
    my $export;
    ok( !eval { $export = Git::FastExport->new(@args); 1 },
        "Git::FastExport->new($desc) failed" );
    like( $@, $regex, 'Expected error message' );
    is( $export, undef, 'No object created' );
}

