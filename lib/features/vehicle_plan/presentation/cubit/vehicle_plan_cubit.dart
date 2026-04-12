import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan_detail.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/usecases/create_vehicle_plan_detail.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/usecases/get_vehicle_plan_details.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/usecases/get_vehicle_plans.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/usecases/update_vehicle_plan.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/usecases/update_vehicle_plan_detail.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/usecases/update_vehicle_plan_detail_status.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/usecases/update_vehicle_plan_status.dart';

import 'vehicle_plan_state.dart';

class VehiclePlanCubit extends Cubit<VehiclePlanState> {
  final GetVehiclePlans _getVehiclePlans;
  final GetVehiclePlanDetails _getVehiclePlanDetails;
  final UpdateVehiclePlan _updateVehiclePlan;
  final UpdateVehiclePlanStatus _updateVehiclePlanStatus;
  final CreateVehiclePlanDetail _createVehiclePlanDetail;
  final UpdateVehiclePlanDetail _updateVehiclePlanDetail;
  final UpdateVehiclePlanDetailStatus _updateVehiclePlanDetailStatus;

  List<VehiclePlan> _plans = const [];
  List<VehiclePlanDetail> _details = const [];
  String? _selectedPlanId;

  VehiclePlanCubit({
    required GetVehiclePlans getVehiclePlans,
    required GetVehiclePlanDetails getVehiclePlanDetails,
    required UpdateVehiclePlan updateVehiclePlan,
    required UpdateVehiclePlanStatus updateVehiclePlanStatus,
    required CreateVehiclePlanDetail createVehiclePlanDetail,
    required UpdateVehiclePlanDetail updateVehiclePlanDetail,
    required UpdateVehiclePlanDetailStatus updateVehiclePlanDetailStatus,
  })  : _getVehiclePlans = getVehiclePlans,
        _getVehiclePlanDetails = getVehiclePlanDetails,
        _updateVehiclePlan = updateVehiclePlan,
        _updateVehiclePlanStatus = updateVehiclePlanStatus,
        _createVehiclePlanDetail = createVehiclePlanDetail,
        _updateVehiclePlanDetail = updateVehiclePlanDetail,
        _updateVehiclePlanDetailStatus = updateVehiclePlanDetailStatus,
        super(const VehiclePlanInitial());

  Future<void> fetchInitial() async {
    emit(const VehiclePlanLoading());

    final result = await _getVehiclePlans(const NoParams());
    switch (result) {
      case Success(:final data):
        _plans = data;
        if (_plans.isEmpty) {
          _selectedPlanId = null;
          _details = const [];
          emit(_loaded());
          return;
        }

        _selectedPlanId ??= _plans.first.id;
        await _loadDetails();
        emit(_loaded());
      case Err(:final failure):
        emit(VehiclePlanError(
          message: failure.message,
          plans: _plans,
          details: _details,
          selectedPlanId: _selectedPlanId,
        ));
    }
  }

  Future<void> selectPlan(String planId) async {
    if (_selectedPlanId == planId) return;
    _selectedPlanId = planId;
    await _loadDetails();
    emit(_loaded());
  }

  Future<void> updatePlanDescription({required String planId, required String descripcion}) async {
    final result = await _updateVehiclePlan(
      UpdateVehiclePlanParams(planId: planId, data: {'descripcion_general': descripcion}),
    );

    switch (result) {
      case Success():
        await fetchInitial();
        emit(_success('Plan actualizado.'));
        emit(_loaded());
      case Err(:final failure):
        emit(_error(failure.message));
    }
  }

  Future<void> updatePlanStatus({required String planId, required String estado, String? motivo}) async {
    final result = await _updateVehiclePlanStatus(
      UpdateVehiclePlanStatusParams(planId: planId, estado: estado, motivo: motivo),
    );

    switch (result) {
      case Success():
        await fetchInitial();
        emit(_success('Estado del plan actualizado.'));
        emit(_loaded());
      case Err(:final failure):
        emit(_error(failure.message));
    }
  }

  Future<void> createDetail({required String planId, required Map<String, dynamic> data}) async {
    final result = await _createVehiclePlanDetail(
      CreateVehiclePlanDetailParams(planId: planId, data: data),
    );

    switch (result) {
      case Success():
        _selectedPlanId = planId;
        await _loadDetails();
        emit(_success('Detalle agregado correctamente.'));
        emit(_loaded());
      case Err(:final failure):
        emit(_error(failure.message));
    }
  }

  Future<void> updateDetail({required String detailId, required Map<String, dynamic> data}) async {
    final result = await _updateVehiclePlanDetail(
      UpdateVehiclePlanDetailParams(detailId: detailId, data: data),
    );

    switch (result) {
      case Success():
        await _loadDetails();
        emit(_success('Detalle actualizado correctamente.'));
        emit(_loaded());
      case Err(:final failure):
        emit(_error(failure.message));
    }
  }

  Future<void> updateDetailStatus({required String detailId, required String estado, String? motivo}) async {
    final result = await _updateVehiclePlanDetailStatus(
      UpdateVehiclePlanDetailStatusParams(detailId: detailId, estado: estado, motivo: motivo),
    );

    switch (result) {
      case Success():
        await _loadDetails();
        emit(_success('Estado del servicio actualizado.'));
        emit(_loaded());
      case Err(:final failure):
        emit(_error(failure.message));
    }
  }

  Future<void> _loadDetails() async {
    final selected = _selectedPlanId;
    if ((selected ?? '').isEmpty) {
      _details = const [];
      return;
    }

    final result = await _getVehiclePlanDetails(
      GetVehiclePlanDetailsParams(planId: selected!),
    );
    if (result is Success<List<VehiclePlanDetail>>) {
      _details = result.data;
    }
  }

  VehiclePlanLoaded _loaded() => VehiclePlanLoaded(
        plans: _plans,
        details: _details,
        selectedPlanId: _selectedPlanId,
      );

  VehiclePlanSuccess _success(String message) => VehiclePlanSuccess(
        message: message,
        plans: _plans,
        details: _details,
        selectedPlanId: _selectedPlanId,
      );

  VehiclePlanError _error(String message) => VehiclePlanError(
        message: message,
        plans: _plans,
        details: _details,
        selectedPlanId: _selectedPlanId,
      );
}

