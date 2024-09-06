import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Politique de Confidentialité',
          style: GoogleFonts.poppins(fontSize: manageWidth(context, 17)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(manageWidth(context, 6.0)),
        child: Text(
          '''
Politique de Confidentialité de TradHart
Dernière mise à jour : 07 juin 2024

TradHart s'engage à protéger la vie privée de ses utilisateurs, qu'ils soient vendeurs, prestataires de services ou acheteurs. La présente Politique de Confidentialité décrit comment nous collectons, utilisons, partageons et protégeons vos informations personnelles lorsque vous utilisez notre marketplace digitale. En accédant à notre site ou en utilisant nos services, vous acceptez les pratiques décrites dans cette politique.

1. Informations Collectées
1.1 Informations fournies par les utilisateurs

Vendeurs et Prestataires de Services : Lors de l'inscription, nous collectons des informations telles que votre nom, adresse email, numéro de téléphone, adresse physique, informations de paiement, et description des services ou produits.
Acheteurs : Lors de l'inscription et de l'achat, nous collectons des informations telles que votre nom, adresse email, numéro de téléphone, adresse de livraison, et informations de paiement.
1.2 Informations collectées automatiquement

Données de navigation : Nous collectons des informations telles que votre adresse IP, type de navigateur, pages visitées, durée des visites, et autres données de navigation à des fins d'analyse et d'amélioration de nos services.
Cookies et technologies similaires : Nous utilisons des cookies et autres technologies de suivi pour personnaliser votre expérience et analyser l'utilisation de notre site.
2. Utilisation des Informations
2.1 Fourniture des services

Utiliser vos informations pour faciliter les transactions entre acheteurs et vendeurs/prestataires de services.
Gérer votre compte et fournir un support client.
2.2 Amélioration et personnalisation

Analyser l'utilisation du site pour améliorer nos services.
Personnaliser votre expérience en fonction de vos préférences et comportements.
2.3 Communication

Vous envoyer des notifications relatives à votre compte ou à vos transactions.
Vous informer des mises à jour, offres spéciales, et autres communications marketing (avec votre consentement).
3. Partage des Informations
3.1 Avec les vendeurs et prestataires de services

Nous partageons les informations nécessaires aux transactions (ex : nom, adresse de livraison) avec les vendeurs/prestataires de services pour exécuter les commandes.
3.2 Prestataires de services tiers

Nous pouvons partager vos informations avec des prestataires de services tiers qui nous aident à opérer notre site, traiter les paiements, analyser les données, etc. Ces tiers sont contractuellement obligés de protéger vos informations et de les utiliser uniquement aux fins pour lesquelles elles ont été partagées.
3.3 Obligations légales

Nous pouvons divulguer vos informations si cela est requis par la loi ou pour répondre à des demandes légales ou protéger nos droits, votre sécurité ou celle des autres.
4. Sécurité des Informations
Nous mettons en œuvre des mesures de sécurité techniques et organisationnelles appropriées pour protéger vos informations personnelles contre la perte, l'utilisation abusive, l'accès non autorisé, la divulgation ou la destruction. Cependant, aucune transmission de données sur Internet n'est totalement sécurisée. Par conséquent, nous ne pouvons garantir la sécurité absolue de vos informations.

5. Conservation des Données
Nous conservons vos informations personnelles aussi longtemps que nécessaire pour fournir nos services, respecter nos obligations légales, résoudre les litiges, et faire appliquer nos accords. Les critères utilisés pour déterminer nos périodes de conservation incluent la nature des informations, la durée de la relation client, les exigences légales et la défense de nos intérêts légaux.

6. Vos Droits
6.1 Accès et rectification

Vous avez le droit d'accéder à vos informations personnelles et de demander leur rectification si elles sont inexactes ou incomplètes.
6.2 Suppression et opposition

Vous pouvez demander la suppression de vos informations personnelles ou vous opposer à leur traitement sous certaines conditions.
6.3 Portabilité des données

Vous avez le droit de demander que vos informations personnelles vous soient fournies dans un format structuré, couramment utilisé et lisible par machine.
Pour exercer ces droits, veuillez nous contacter à l'adresse email suivante : contact@tradhart.com.

7. Modifications de la Politique de Confidentialité
Nous nous réservons le droit de modifier cette Politique de Confidentialité à tout moment. Toute modification sera publiée sur cette page et, si les modifications sont significatives, nous vous en informerons par email ou via une notification sur notre site. Votre utilisation continue de notre site après la publication des modifications constitue votre acceptation de ces modifications.

8. Contact
Si vous avez des questions ou des préoccupations concernant cette Politique de Confidentialité, veuillez nous contacter à :

TradeHart
5 rue des Essarts, 45140 Saint-Jean-de-la-Ruelle, France
contact@tradhart.com
07 51 25 88 37 

Nous vous remercions d'avoir choisi TradeHart. Votre confiance et votre satisfaction sont nos priorités.
          ''',
          style: GoogleFonts.poppins(fontSize: 14.0),
        ),
      ),
    );
  }
}
