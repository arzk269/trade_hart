import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';

class PresentationPage extends StatelessWidget {
  const PresentationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'A propos de nous',
          style: GoogleFonts.poppins(fontSize: manageWidth(context, 17)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(manageWidth(context, 6.0)),
        child: Text(
          '''
Bienvenue sur TradeHart, votre marketplace digitale dédiée à la vente de services en ligne et d'articles de qualité. Chez TradeHart, nous croyons en la puissance de la connexion et de l'échange pour enrichir la vie des individus et des entreprises.

Notre Mission
Chez TradeHart, notre mission est de fournir une plateforme conviviale et sécurisée où les vendeurs, les prestataires de services et les acheteurs peuvent se rencontrer, échanger et prospérer. Nous visons à faciliter les transactions tout en garantissant la satisfaction de nos utilisateurs par des services fiables et de haute qualité.

Nos Valeurs
Confiance et Sécurité : La sécurité de nos utilisateurs est notre priorité absolue. Nous mettons en œuvre des mesures robustes pour protéger vos données personnelles et assurer des transactions sécurisées.
Qualité et Excellence : Nous nous engageons à offrir une sélection de services et de produits qui répondent aux normes les plus élevées de qualité et d'excellence.
Communauté et Collaboration : TradeHart est plus qu'une marketplace ; c'est une communauté dynamique où les utilisateurs peuvent se connecter, collaborer et se soutenir mutuellement.
Ce que Nous Offrons
Pour les Vendeurs et Prestataires de Services :

Visibilité : Profitez d'une plateforme bien conçue pour présenter vos produits et services à un large public.
Simplicité : Gérez facilement vos listings, suivez vos commandes et interagissez avec vos clients grâce à notre interface utilisateur intuitive.
Support : Bénéficiez de notre assistance dédiée pour vous aider à réussir et à croître sur notre marketplace.
Pour les Acheteurs :

Diversité : Explorez une vaste gamme de services et de produits de qualité répondant à tous vos besoins.
Fiabilité : Achetez en toute confiance grâce à notre système de vérification des vendeurs et aux avis des clients.
Facilité : Découvrez une expérience d'achat fluide et agréable avec des options de paiement sécurisées et un support client réactif.
Notre Histoire
Fondée par une équipe passionnée de l'innovation numérique et du commerce électronique, TradeHart est née de la vision de créer un espace où la qualité rencontre la commodité. Inspirés par les besoins des vendeurs et des acheteurs modernes, nous avons construit TradeHart pour être une plateforme adaptable et en constante évolution.

Rejoignez-Nous
Que vous soyez un vendeur cherchant à atteindre de nouveaux clients ou un acheteur à la recherche de services et de produits exceptionnels, TradeHart est la place qu'il vous faut. Rejoignez notre communauté dès aujourd'hui et découvrez une nouvelle manière de vendre, d'acheter et de collaborer.

Contactez-nous :

TradeHart
5 rue des Essarts, 45140 Saint-Jean-de-la-Ruelle, France
contact.tradehart@gmail.com
07 51 25 88 37 

Merci de faire partie de notre aventure. Ensemble, faisons de TradeHart la référence de la marketplace digitale de confiance.

          ''',
          style: GoogleFonts.poppins(fontSize: 14.0),
        ),
      ),
    );
  }
}
