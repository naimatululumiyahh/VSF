// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volunteer_registration.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VolunteerRegistrationAdapter extends TypeAdapter<VolunteerRegistration> {
  @override
  final int typeId = 3;

  @override
  VolunteerRegistration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VolunteerRegistration(
      id: fields[0] as String,
      eventId: fields[1] as String,
      volunteerId: fields[2] as String,
      volunteerName: fields[3] as String,
      volunteerEmail: fields[4] as String,
      volunteerPhone: fields[5] as String,
      volunteerNik: fields[6] as String?,
      birthDate: fields[7] as DateTime,
      agreementNonRefundable: fields[8] as bool,
      motivation: fields[9] as String,
      donationAmount: fields[10] as int,
      paymentMethod: fields[11] as String,
      isPaid: fields[12] as bool,
      registeredAt: fields[13] as DateTime?,
      feedbackMessage: fields[14] as String?,
      feedbackSubmittedAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, VolunteerRegistration obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.eventId)
      ..writeByte(2)
      ..write(obj.volunteerId)
      ..writeByte(3)
      ..write(obj.volunteerName)
      ..writeByte(4)
      ..write(obj.volunteerEmail)
      ..writeByte(5)
      ..write(obj.volunteerPhone)
      ..writeByte(6)
      ..write(obj.volunteerNik)
      ..writeByte(7)
      ..write(obj.birthDate)
      ..writeByte(8)
      ..write(obj.agreementNonRefundable)
      ..writeByte(9)
      ..write(obj.motivation)
      ..writeByte(10)
      ..write(obj.donationAmount)
      ..writeByte(11)
      ..write(obj.paymentMethod)
      ..writeByte(12)
      ..write(obj.isPaid)
      ..writeByte(13)
      ..write(obj.registeredAt)
      ..writeByte(14)
      ..write(obj.feedbackMessage)
      ..writeByte(15)
      ..write(obj.feedbackSubmittedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VolunteerRegistrationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
