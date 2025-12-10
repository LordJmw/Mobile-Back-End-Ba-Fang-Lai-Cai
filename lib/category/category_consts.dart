import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';

class CategoryConst {
  static const photography = "photography";
  static const eventOrganizer = "event_organizer";
  static const makeupFashion = "makeup_fashion";
  static const entertainment = "entertainment";
  static const decorVenue = "decor_venue";
  static const cateringFB = "catering_fb";
  static const techEventProduction = "tech_event_production";
  static const transportationLogistics = "transportation_logistics";
  static const supportServices = "support_services";

  static const Map<String, String> dbLabelToCode = {
    "Fotografi & Videografi": photography,
    "Event Organizer & Planner": eventOrganizer,
    "Makeup & Fashion": makeupFashion,
    "Entertainment & Performers": entertainment,
    "Dekorasi & Venue": decorVenue,
    "Catering & F&B": cateringFB,
    "Teknologi & Produksi Acara": techEventProduction,
    "Transportasi & Logistik": transportationLogistics,
    "Layanan Pendukung Lainnya": supportServices,
  };

  static const Map<String, String> codeToDbLabel = {
    photography: "Fotografi & Videografi",
    eventOrganizer: "Event Organizer & Planner",
    makeupFashion: "Makeup & Fashion",
    entertainment: "Entertainment & Performers",
    decorVenue: "Dekorasi & Venue",
    cateringFB: "Catering & F&B",
    techEventProduction: "Teknologi & Produksi Acara",
    transportationLogistics: "Transportasi & Logistik",
    supportServices: "Layanan Pendukung Lainnya",
  };

  static List<Map<String, dynamic>> getLocalizedCategories(
    AppLocalizations l10n,
  ) {
    return [
      {
        "icon": Icons.camera_alt_outlined,
        "label": l10n.categoryPhotography,
        "code": photography,
      },
      {
        "icon": Icons.event,
        "label": l10n.categoryEventOrganizer,
        "code": eventOrganizer,
      },
      {
        "icon": Icons.brush,
        "label": l10n.categoryMakeupFashion,
        "code": makeupFashion,
      },
      {
        "icon": Icons.music_note,
        "label": l10n.categoryEntertainment,
        "code": entertainment,
      },
      {
        "icon": Icons.chair,
        "label": l10n.categoryDecorVenue,
        "code": decorVenue,
      },
      {
        "icon": Icons.restaurant,
        "label": l10n.categoryCateringFB,
        "code": cateringFB,
      },
      {
        "icon": Icons.tv,
        "label": l10n.categoryTechEventProduction,
        "code": techEventProduction,
      },
      {
        "icon": Icons.local_shipping,
        "label": l10n.categoryTransportationLogistics,
        "code": transportationLogistics,
      },
      {
        "icon": Icons.handshake,
        "label": l10n.categorySupportServices,
        "code": supportServices,
      },
    ];
  }
}
