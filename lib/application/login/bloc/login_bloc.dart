  import 'package:bloc/bloc.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:habit_tracker/application/login/bloc/login_event.dart';
  import 'package:habit_tracker/application/login/bloc/login_state.dart';

  class LoginBloc extends Bloc<LoginEvent, LoginState> {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    LoginBloc() : super(LoginInitial()) {
      on<LoginRequested>(_onLoginRequest);
    }

    Future<void> _onLoginRequest(
        LoginRequested event, Emitter<LoginState> emit) async {
      emit(LoginLoading());

      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        final user = userCredential.user;
        if (user != null) {
          emit(LoginSuccess(message: "Login berhasil. Selamat datang kembali!"));
        } else {
          emit(LoginFailure(error: "Login gagal. User tidak ditemukan."));
        }
      } on FirebaseAuthException catch (e) {
        String errorMsg = "Terjadi kesalahan saat login.";
        print("FirebaseAuthException code: ${e.code}");
        print("FirebaseAuthException message: ${e.message}");

        if (e.code == 'user-not-found') {
          errorMsg = "Pengguna tidak ditemukan.";
        } else if (e.code == 'wrong-password') {
          errorMsg = "Password salah.";
        } else if (e.code == 'invalid-email') {
          errorMsg = "Email tidak valid.";
        }

        emit(LoginFailure(error: errorMsg));
      } catch (e) {
        emit(LoginFailure(error: "Login gagal. Coba lagi nanti."));
      }
    }
  }
