# Copyright (c) 2022-2023, PostgreSQL Global Development Group

psql_sources = files(
  'command.c',
  'common.c',
  'copy.c',
  'crosstabview.c',
  'input.c',
  'large_obj.c',
  'mainloop.c',
  'prompt.c',
  'startup.c',
  'stringutils.c',
  'tab-complete.c',
  'variables.c',
)

psqlscanslash = custom_target('psqlscanslash',
  input: 'psqlscanslash.l',
  output: 'psqlscanslash.c',
  command: [flex_cmd, '--no-backup', '--fix-warnings', '--', '-Cfe', '-p', '-p'])
generated_sources += psqlscanslash
psql_sources += psqlscanslash

if host_system == 'windows'
  psql_sources += rc_bin_gen.process(win32ver_rc, extra_args: [
    '--NAME', 'psql',
    '--FILEDESC', 'psql - the PostgreSQL interactive terminal',])
endif

psql = executable('psql',
  psql_sources,
  c_pch: pch_postgres_fe_h,
  include_directories: include_directories('.'),
  dependencies: [frontend_code, libpq, readline],
  kwargs: default_bin_args,
)
bin_targets += psql

install_data('psqlrc.sample',
  install_dir: dir_data,
)

tests += {
  'name': 'psql',
  'sd': meson.current_source_dir(),
  'bd': meson.current_build_dir(),
  'tap': {
    'env': {'with_readline': readline.found() ? 'yes' : 'no'},
    'tests': [
      't/001_basic.pl',
      't/010_tab_completion.pl',
      't/020_cancel.pl',
    ],
  },
}

subdir('po', if_found: libintl)
