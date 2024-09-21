import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../extension/hex_extension_string.dart';
import '../../models/hrt_comm.dart';
import '../../models/hrt_build.dart';
import '../../models/hrt_frame.dart';
import '../../models/hrt_storage.dart';

class HomeController extends Disposable {
  late final HrtComm hrtComm;
  final connectNotifier = ValueNotifier<String>("");
  final sendNotifier = ValueNotifier<String>("");
  String masterSlave = "01";
  final hrtFrameWrite = HrtFrame();
  final hrtStorage = HrtStorage();
  final textController = TextEditingController();
  final commandController = TextEditingController();
  final completer = Completer<bool>();

  HomeController(this.hrtComm) {
    completer.complete(hrtStorage.init());
  }

  void readHrtFrame(String data) {
    final hrtResponse = HrtFrame(data);
    final aux = hrtResponse.frame.splitByLength(2).join(" ");
    textController.text += aux;
    if (kDebugMode) {
      print(aux);
    }
  }

  bool masterMode(String commandWrite) {
    hrtStorage.setVariable(
        'master_address', masterSlave); //Seta para primario master
    hrtStorage.setVariable('frame_type',
        masterSlave == '01' ? "02" : "06"); //Do master para o device
    final hrtFrameRead = HrtFrame()
      ..command = commandWrite == "" ? "00" : commandWrite;
    if (hrtFrameRead.log.isEmpty) {
      final hrtRequest = HrtBuild(hrtStorage, hrtFrameRead);
      final valueAux = hrtRequest.frame;
      hrtComm.writeFrame(valueAux);
      final aux = '${valueAux.splitByLength(2).join(" ")} -> ';
      textController.text += aux;
      if (kDebugMode) {
        print(aux);
      }
      return true;
    }
    return false;
  }

  Future<bool> slaveMode(String frameRead) async {
    hrtStorage.setVariable(
        'master_address', masterSlave); //quando Slave deve ser 0
    hrtStorage.setVariable('frame_type', "06"); //Do device para o master
    final hrtFrameRead = HrtFrame(frameRead);
    if (hrtFrameRead.log.isEmpty) {
      final hrtResponse = HrtBuild(hrtStorage, hrtFrameRead);
      textController.text +=
          '${hrtFrameRead.frame.splitByLength(2).join(" ")} -> ${hrtResponse.frame.splitByLength(2).join(" ")}\n';
      hrtComm.writeFrame(hrtResponse.frame);
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    hrtComm.disconnect();
  }
}
