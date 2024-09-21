import 'package:flutter_modular/flutter_modular.dart';
import '../../models/hrt_comm.dart';
import 'home_controller.dart';
import 'home_page.dart';


class HomeModule extends Module {
  @override
  void binds(Injector i) {
    i.addInstance<HrtComm>(HrtComm());    
    i.add<HomeController>(HomeController.new);         
  }

  @override
  void routes(r) {
    r.child('/', child: (_) => const HomePage());  
  }
}
