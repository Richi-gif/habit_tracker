import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_tracker/application/register/bloc/register_event.dart';
import 'package:habit_tracker/application/register/bloc/register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterRequested>(_onRegisterRequest);
  }

  Future<void> _onRegisterRequest(
      RegisterRequested event, Emitter<RegisterState> emit) async {
    emit(RegisterLoading());
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Opsional: simpan display name
        await user.updateDisplayName(event.name);

        emit(RegisterSuccess(message: "Registrasi berhasil. Selamat datang!"));
      } else {
        emit(RegisterFailure(error: "Gagal registrasi. User tidak dibuat."));
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = "Registrasi gagal.";
      if (e.code == 'email-already-in-use') {
        errorMsg = "Email sudah digunakan.";
      } else if (e.code == 'weak-password') {
        errorMsg = "Password terlalu lemah.";
      } else if (e.code == 'invalid-email') {
        errorMsg = "Format email tidak valid.";
      }
      emit(RegisterFailure(error: errorMsg));
    } catch (e) {
      emit(RegisterFailure(error: "Terjadi kesalahan saat registrasi."));
    }
  }
}
