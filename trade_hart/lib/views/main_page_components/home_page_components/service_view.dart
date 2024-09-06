import 'package:flutter/material.dart';
import 'package:trade_hart/model/service.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/service_view_component/service_container.dart';

class ServiceView extends StatefulWidget {
  final Service service;
  const ServiceView({super.key, required this.service});

  @override
  State<ServiceView> createState() => _ServiceViewState();
}

class _ServiceViewState extends State<ServiceView> {
  @override
  Widget build(BuildContext context) {
    return ServiceContainer(service: widget.service);
  }
}
