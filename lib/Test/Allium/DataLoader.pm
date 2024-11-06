
use v5.40;
use experimental qw[ class ];

use importer 'Path::Tiny' => qw[ path ];
use importer 'List::Util' => qw[ shuffle ];

use JSON       ();
use B::Concise ();

use A;
use Allium::Optree::Dumper;

class Test::Allium::DataLoader {
    field $data_dir :param :reader;

    field @code;

    ADJUST {
        $data_dir = path($data_dir) unless blessed $data_dir;
    }

    method create_new_code_file {
        my $next = $code[-1]->id + 1;
        $data_dir->child('code')
                 ->child(sprintf '%03d-sub.pl' => $next)
                 ->spew(join "\n" => (
                    '#!perl',
                    '',
                    'use v5.40;',
                    '',
                    (sprintf 'sub sub_%03d {' => $next),
                    '',
                    '}',
                    '',
                 ));
    }

    method shuffle_code { shuffle @code }

    method load_all_code {
        return $self if scalar @code;

        my $disassembler = A->new->op_disassembler;
        @code = map {
            #warn "Loading $_";
            Test::Allium::DataLoader::Code->new(
                disassembler => $disassembler,
                data_dir     => $data_dir,
                code_file    => $_,
            )
        } sort { $a->basename cmp $b->basename }
            $data_dir->child('code')->children( qr/\.pl$/ );

        $self;
    }

    method write_initial_data_set {
        $_->load_optree->write_initial_code_data foreach @code;
        $self;
    }
}

class Test::Allium::DataLoader::Code {
    field $disassembler :param :reader;
    field $data_dir     :param :reader;
    field $code_file    :param :reader;

    field $id      :reader;
    field $subname :reader;

    field $cv     :reader;
    field $source :reader;

    field $optree  :reader;
    field $allium  :reader;
    field $concise :reader;

    my $JSON = JSON->new->pretty->canonical->boolean_values(false, true);

    ADJUST {
        ($id) = ($code_file->basename =~ /^(\d\d\d)-sub\.pl$/ );
        $subname = sprintf 'sub_%03d' => int($id);
    }

    method load_optree {
        $source = $code_file->slurp;
        eval $source;
        if ($@) {
            die "Unable to load code($code_file) because: $@"
        }
        else {
            no strict 'refs';
            $cv = \&{$subname};
        }
        $optree = $disassembler->disassemble($cv);

        $self;
    }

    method load_allium {
        my $json = $self->read_allium_file;
        $allium = $JSON->decode( $json );
        $self;
    }

    method load_concise {
        $concise = $self->read_concise_file;
        $self;
    }

    method dump_optree {
        Allium::Optree::Dumper->new->dump($optree)
    }

    method dump_concise {
        my $cmd = sprintf 'perl -MO=Concise,%s -I lib %s 2> /dev/null' => $subname, $code_file;
        my $out = `$cmd`;
        return $out;
    }

    method get_allium_file_name  { $code_file->basename =~ s/\.pl$/\.json/r    }
    method get_concise_file_name { $code_file->basename =~ s/\.pl$/\.concise/r }

    method get_allium_file  { $data_dir->child('allium')->child($self->get_allium_file_name)   }
    method get_concise_file { $data_dir->child('concise')->child($self->get_concise_file_name) }

    method read_allium_file  { $self->get_allium_file->slurp  }
    method read_concise_file { $self->get_concise_file->slurp }

    method write_allium_file  ($data) { $self->get_allium_file->spew($data)  }
    method write_concise_file ($data) { $self->get_concise_file->spew($data) }

    method write_initial_code_data {
        #warn "Writing ",$self->get_allium_file_name;
        $self->write_allium_file ( $JSON->encode( $self->dump_optree ) );
        #warn "Writing ",$self->get_concise_file_name;
        $self->write_concise_file( $self->dump_concise );
        $self;
    }
}


__END__

foreach my $code (\&foo, \&bar, \&baz, \&gorch, \&bling, \&fling) {
    my $name = Sub::Util::subname($code);
    subtest "... testing load/dump for code($name)[".(refaddr $code)."]" => sub {
        my $orig = A->new->op_disassembler->disassemble($code);
        isa_ok($orig, 'Allium::Optree');

        #$orig->walk(top_down  => sub ($op) { say sprintf '%s(%s)' => $op->type, $op->name });

        my $dump1 = Allium::Optree::Dumper->new->dump($orig);

        use YAML qw[ Dump ];
        warn Dump $dump1->{pad};

        my $copy  = Allium::Optree::Loader->new->load($dump1);
        isa_ok($copy, 'Allium::Optree');

        #$copy->walk(top_down  => sub ($op) {
        #    return unless $op isa Allium::Operation::SVOP;
        #    say sprintf 'OP(%s) : SYM(%s) = VAL(%s)' =>
        #        ($op->name // '~'),
        #        ($op->binding->symbol ? $op->binding->symbol->full_name : '~'),
        #        ($op->binding->value // '~'),
        #    ;
        #});

        my $dump2 = Allium::Optree::Dumper->new->dump($copy);

        #use YAML qw[ Dump ];
        #warn Dump $dump2;

        isa_ok($orig, 'Allium::Optree');
        isa_ok($copy, 'Allium::Optree');
        is($orig->root->addr, $copy->root->addr, '... the roots are identical');
        is($orig->start->addr, $copy->start->addr, '... the starts are identical');
        eq_or_diff($dump1, $dump2, '... the op dumps are identical');
    };
}
