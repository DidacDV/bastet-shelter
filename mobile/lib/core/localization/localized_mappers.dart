import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/adoption/data/adoption_enums.dart';
import 'package:bastetshelter/features/community/data/advertisement_model.dart';
import 'package:bastetshelter/features/medical_treatments/data/models/medical_treatment_model.dart';
import 'package:bastetshelter/features/medicine/data/models/vet_visit_model.dart';
import 'package:flutter/material.dart';

extension LocalizedMappers on BuildContext {
  String localizedAdCategory(AdCategory category) => switch (category) {
    AdCategory.food => l10n.t('community.categoryFood'),
    AdCategory.medicine => l10n.t('community.categoryMedicine'),
    AdCategory.equipment => l10n.t('community.categoryEquipment'),
    AdCategory.toys => l10n.t('community.categoryToys'),
    AdCategory.other => l10n.t('community.categoryOther'),
  };

  String localizedAdoptionProcessStatus(AdoptionProcessStatus status) =>
      switch (status) {
        AdoptionProcessStatus.pending => l10n.t('adoption.statusPending'),
        AdoptionProcessStatus.completed => l10n.t('adoption.statusCompleted'),
        AdoptionProcessStatus.cancelled => l10n.t('adoption.statusCancelled'),
        AdoptionProcessStatus.rejected => l10n.t('adoption.statusRejected'),
      };

  String localizedAdoptionStepType(
    StepType type, {
    bool shortAnimalPickup = false,
  }) => switch (type) {
    StepType.form => l10n.t('adoption.stepForm'),
    StepType.interview => l10n.t('adoption.stepInterview'),
    StepType.shelterVisit => l10n.t('adoption.stepShelterVisit'),
    StepType.contract => l10n.t('adoption.stepContract'),
    StepType.animalPickup => l10n.t(
      shortAnimalPickup
          ? 'adoption.stepAnimalPickupShort'
          : 'adoption.stepAnimalPickup',
    ),
  };

  String localizedAdoptionStepStatus(StepStatus status) => switch (status) {
    StepStatus.pending => l10n.t('adoption.statusPending'),
    StepStatus.completed => l10n.t('adoption.statusCompleted'),
    StepStatus.rejected => l10n.t('adoption.statusRejected'),
    StepStatus.skipped => l10n.t('adoption.statusSkipped'),
  };

  String localizedMedicineFrequency(MedicineFrequency frequency) =>
      switch (frequency) {
        MedicineFrequency.daily => l10n.t('medical.frequencyDaily'),
        MedicineFrequency.weekly => l10n.t('medical.frequencyWeekly'),
        MedicineFrequency.monthly => l10n.t('medical.frequencyMonthly'),
        MedicineFrequency.asNeeded => l10n.t('medical.frequencyAsNeeded'),
      };

  String localizedMedicineStatus(MedicineStatus status) => switch (status) {
    MedicineStatus.given => l10n.t('medical.statusGiven'),
    MedicineStatus.pending => l10n.t('medical.statusPending'),
  };

  String localizedDosageUnit(DosageUnit unit) => switch (unit) {
    DosageUnit.mg => l10n.t('medical.unitMg'),
    DosageUnit.ml => l10n.t('medical.unitMl'),
    DosageUnit.drops => l10n.t('medical.unitDrops'),
    DosageUnit.units => l10n.t('medical.unitUnits'),
  };

  String localizedVetVisitType(VetVisitType type) => switch (type) {
    VetVisitType.generalCheckup => l10n.t('vet.typeGeneralCheckup'),
    VetVisitType.vaccine => l10n.t('vet.typeVaccine'),
    VetVisitType.surgery => l10n.t('vet.typeSurgery'),
    VetVisitType.dental => l10n.t('vet.typeDental'),
    VetVisitType.emergency => l10n.t('vet.typeEmergency'),
    VetVisitType.other => l10n.t('vet.typeOther'),
  };
}
