# Copyright (c) 2022-2024, PostgreSQL Global Development Group

hook_sources = files(
  'hook.c',
)

if host_system == 'windows'
  hook_sources += rc_lib_gen.process(win32ver_rc, extra_args: [
    '--NAME', 'hook',
    '--FILEDESC', 'hook - Postgres hook statistics',])
endif

hook = shared_module('hook',
  hook_sources,
  kwargs: contrib_mod_args + {
    'dependencies': contrib_mod_args['dependencies'],
  },
)
contrib_targets += hook

install_data(
  'hook.control',
  'hook--1.0.sql',
  kwargs: contrib_data_args,
)

tests += {
  'name': 'hook',
  'sd': meson.current_source_dir(),
  'bd': meson.current_build_dir(),
  'regress': {
    'sql': [
      '101_hook',
      '102_hook',
      '103_hook',
      '111_hook',
      '112_hook',
      '113_hook',
      '114_hook',
      '121_hook',
      '122_hook',
      '131_hook',
      '132_hook',
    ],
    'regress_args': ['--temp-config', files('hook.conf')],
    'runningcheck': false,
  },
  'tap': {
    'tests': [
      't/010_restart.pl',
    ],
  },
}
