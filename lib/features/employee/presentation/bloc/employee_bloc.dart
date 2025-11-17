import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/employee_repository.dart';
import 'employee_event.dart';
import 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository employeeRepository;

  EmployeeBloc({required this.employeeRepository}) : super(EmployeeInitial()) {
    on<LoadEmployees>(_onLoadEmployees);
    on<AddEmployee>(_onAddEmployee);
    on<DeleteEmployee>(_onDeleteEmployee);
  }

  Future<void> _onLoadEmployees(
    LoadEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeeLoading());
    try {
      final employees = await employeeRepository.getEmployees(event.token);
      emit(EmployeeLoaded(employees));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<void> _onAddEmployee(
    AddEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeeLoading());
    try {
      await employeeRepository.addEmployee(
        token: event.token,
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(const EmployeeOperationSuccess('Employee added successfully'));
      // Reload employees
      final employees = await employeeRepository.getEmployees(event.token);
      emit(EmployeeLoaded(employees));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<void> _onDeleteEmployee(
    DeleteEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeeLoading());
    try {
      await employeeRepository.deleteEmployee(event.token, event.empId);
      emit(const EmployeeOperationSuccess('Employee deleted successfully'));
      // Reload employees
      final employees = await employeeRepository.getEmployees(event.token);
      emit(EmployeeLoaded(employees));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }
}
