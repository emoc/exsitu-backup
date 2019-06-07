/* ***********************************************************
 Pour le projet Backup de Exsitu
 Réception de messages OSC envoyés par pure data 
 Quimper, Dour Ru, 7 juin 2019 / pierre@lesporteslogiques.net
 processing 3.4 @ kirin
 
 Messages transmis par pure data :
 /video/enveloppe/id (float)
 /video/enveloppe/max (float)
 /video/enveloppe/fadein (float)
 /video/enveloppe/decay (float)
 /video/enveloppe/fadeout (float)
 /video/control/color (float)
 
 Ce programme sert à valider la réception des messages.
 On peut utiliser exsitu_backup_emission_osc.pd pour tester
 *********************************************************** */

// Déclaration des objets OSC *********************************
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

// Initialisation des variables  ******************************
float video_enveloppe_id      = 0;
float video_enveloppe_max     = 0;
float video_enveloppe_fadein  = 0;
float video_enveloppe_decay   = 0;
float video_enveloppe_fadeout = 0;
float video_control_color     = 0;


void setup() {
  size(800, 500);
  oscP5 = new OscP5(this, 8003); // écoute des messages OSC sur le port 8003
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
  textFont(police, 15);
}

void draw() {
  background(0);
  noStroke();
  fill(255);
  
  // Affichage des valeurs
  text("/video/enveloppe/id :      " + video_enveloppe_id,      30,  30);
  text("/video/enveloppe/max :     " + video_enveloppe_max,     30,  50);
  text("/video/enveloppe/fadein :  " + video_enveloppe_fadein,  30,  70);
  text("/video/enveloppe/decay :   " + video_enveloppe_decay,   30,  90);
  text("/video/enveloppe/fadeout : " + video_enveloppe_fadeout, 30, 110);
  text("/video/control/color :     " + video_control_color,     30, 130);

}

// Attribution des valeurs aux variables selon les messages OSC reçus 
void oscEvent(OscMessage theOscMessage) {

  if (theOscMessage.checkAddrPattern("/video/enveloppe/id") == true) {
    video_enveloppe_id = theOscMessage.get(0).floatValue();
    return;
  } 
  if (theOscMessage.checkAddrPattern("/video/enveloppe/max") == true) {
    video_enveloppe_max = theOscMessage.get(0).floatValue();
    return;
  } 
  if (theOscMessage.checkAddrPattern("/video/enveloppe/fadein") == true) {
    video_enveloppe_fadein = theOscMessage.get(0).floatValue();
    return;
  } 
  if (theOscMessage.checkAddrPattern("/video/enveloppe/decay") == true) {
    video_enveloppe_decay = theOscMessage.get(0).floatValue();
    return;
  } 
  if (theOscMessage.checkAddrPattern("/video/enveloppe/fadeout") == true) {
    video_enveloppe_fadeout = theOscMessage.get(0).floatValue();
    return;
  } 
  if (theOscMessage.checkAddrPattern("/video/control/color") == true) {
    video_control_color = theOscMessage.get(0).floatValue();
    return;
  }
}
