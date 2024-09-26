import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hrtsimul/src/models/hrt_translate.dart';
import '../../extension/hex_extension_string.dart';
import '../../models/hrt_comm.dart';
import '../../models/hrt_build.dart';
import '../../models/hrt_frame.dart';
import '../../models/hrt_settings.dart';
import '../../models/hrt_storage.dart';

class HomeController extends Disposable {
  late final HrtComm hrtComm;
  late final HrtStorage hrtStorage;
  late final HrtTranslate hrtTranslate;   
  final connectNotifier = ValueNotifier<String>("");  
  final sendNotifier = ValueNotifier<String>("");
  final hrtFrameWrite = HrtFrame();
  final textController = TextEditingController();
  final commandController = TextEditingController();
  final frameType = ValueNotifier<String>("06");
  final selectedInstrument = ValueNotifier<String>(instrumentType[0]);


  HomeController(this.hrtComm){
    hrtStorage = HrtStorage(selectedInstrument);
    hrtTranslate = HrtTranslate(hrtStorage);
  }

  Future<bool> init() async {
    await hrtStorage.init();
    return true;
  }

  void readHrtFrame(String data) {
    final hrtResponse = HrtFrame(data);
    final aux = hrtResponse.frame.splitByLength(2).join(" ");
    if (frameType.value == '06') {
      textController.text += "\n$aux -> ";
      slaveMode(data);
    } else {
      textController.text += aux;
    }
  }

  bool masterMode(String commandWrite) {
    hrtStorage.setVariable('master_address', '80'); //Do device para o master
    hrtStorage.setVariable('frame_type', frameType.value); //Do master para o device
    final hrtFrameRead = HrtFrame()
      ..command = commandWrite == "" ? "00" : commandWrite.padLeft(2, '0');
    if (hrtFrameRead.log.isEmpty) {
      final hrtRequest = HrtBuild(hrtStorage, hrtFrameRead);
      final valueAux = hrtRequest.frame;
      hrtComm.writeFrame(valueAux);
      final aux = '\n${valueAux.splitByLength(2).join(" ")} -> ';
      textController.text += aux;
      if (kDebugMode) {
        print(aux);
      }
      return true;
    }
    return false;
  }

  Future<bool> slaveMode(String frameRead) async {
    //quando slave deve ser 0
    hrtStorage.setVariable('master_address', '80'); //Do device para o master
    hrtStorage.setVariable('frame_type', frameType.value); //Do device para o master
    final hrtFrameRead = HrtFrame(frameRead);
    final hrtResponse = HrtBuild(hrtStorage, hrtFrameRead);
    textController.text += hrtResponse.frame.splitByLength(2).join(" ");
    return hrtComm.writeFrame(hrtResponse.frame);
  }

  @override
  void dispose() {
    hrtComm.disconnect();
  }
}
