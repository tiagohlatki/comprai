// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:comprai/core/di/injection.dart' as _i136;
import 'package:comprai/features/auth/application/login_use_case.dart' as _i567;
import 'package:comprai/features/auth/application/registrar_use_case.dart'
    as _i678;
import 'package:comprai/features/auth/application/sair_use_case.dart' as _i805;
import 'package:comprai/features/auth/data/repositories/auth_repository.dart'
    as _i395;
import 'package:comprai/features/auth/domain/repositories/i_auth_repository.dart'
    as _i427;
import 'package:comprai/features/auth/presentation/bloc/auth_bloc.dart'
    as _i633;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final supabaseModule = _$SupabaseModule();
    gh.lazySingleton<_i454.SupabaseClient>(() => supabaseModule.supabaseClient);
    gh.lazySingleton<_i427.IAuthRepository>(
      () => _i395.AuthRepository(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i805.SairUseCase>(
      () => _i805.SairUseCase(gh<_i427.IAuthRepository>()),
    );
    gh.lazySingleton<_i567.LoginUseCase>(
      () => _i567.LoginUseCase(gh<_i427.IAuthRepository>()),
    );
    gh.lazySingleton<_i678.RegistrarUseCase>(
      () => _i678.RegistrarUseCase(gh<_i427.IAuthRepository>()),
    );
    gh.factory<_i633.AuthBloc>(
      () => _i633.AuthBloc(
        gh<_i567.LoginUseCase>(),
        gh<_i678.RegistrarUseCase>(),
        gh<_i805.SairUseCase>(),
      ),
    );
    return this;
  }
}

class _$SupabaseModule extends _i136.SupabaseModule {}
