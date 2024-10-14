import 'package:flutter_modular/flutter_modular.dart';
import '../../models/hrt_comm.dart';
import 'home_controller.dart';
import 'home_page.dart';


class HomeModule extends Module {
  @override
<<<<<<< HEAD
  void binds(Injector i) {  
=======
  void binds(Injector i) {
    //i.addInstance<HrtComm>(HrtComm());    
>>>>>>> 3325d10ca07d5a21007bcb939403eed22b4f8916
    i.addInstance<HomeController>(HomeController(HrtComm()));         
  }

  @override
  void routes(r) {
    r.child('/', child: (_) => const HomePage());  
  }
}
