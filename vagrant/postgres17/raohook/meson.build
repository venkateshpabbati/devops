# Copyright (c) 2022-2024, PostgreSQL Global Development Group

raohook_sources = files(
  'raohook.c',
)

if host_system == 'windows'
  raohook_sources += rc_lib_gen.process(win32ver_rc, extra_args: [
    '--NAME', 'raohook',
    '--FILEDESC', 'raohook - Postgres hook statistics',])
endif

raohook = shared_module('raohook',
  raohook_sources,
  kwargs: contrib_mod_args + {
    'dependencies': contrib_mod_args['dependencies'],
  },
)
contrib_targets += raohook

install_data(
  'raohook.control',
  'raohook--1.0.sql',
  kwargs: contrib_data_args,
)

tests += {
  'name': 'raohook',
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
    'regress_args': ['--temp-config', files('raohook.conf')],
    'runningcheck': false,
  },
  'tap': {
    'tests': [
      't/010_restart.pl',
    ],
  },
}
