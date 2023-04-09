create table Utente (
	email varchar(50) check (email like '%@%.%'),
	password varchar(25) not null,
	nome varchar(20) not null,
	cognome varchar(20) not null,
	carta_d_identità bytea,
	verificato boolean not null,
	constraint Utente_PK primary key(email)
);

create table Ospite (
	utente varchar(50),
	constraint Ospite_PK primary key(utente),
	constraint Ospite_FK_Utente foreign key(utente) references Utente(email) on update cascade on delete cascade
);

create table Host (
	utente varchar(50),
	superhost boolean not null,
	constraint Host_PK primary key(utente),
	constraint Host_FK_Utente foreign key(utente) references Utente(email) on update cascade on delete cascade
);

create table Alloggio (
	codice_alloggio varchar(15),
	via varchar(30) not null,
	numero_civico smallint not null check (numero_civico > 0),
	comune varchar(25) not null,
	cap integer not null check (cap >= 00000 and cap <= 99999),
	nome varchar(30) not null,
	descrizione text not null,
	prezzo_per_notte float(2) not null check (prezzo_per_notte >= 0),
	numero_di_letti smallint default 1 not null check (numero_di_letti > 0),
	check_in time not null,
	check_out time not null,
	valutazione_media float (1) default 0 not null check (valutazione_media >= 0 and valutazione_media <= 5),
	numero_di_recensioni integer default 0 not null check (numero_di_recensioni >= 0),
	costi_di_pulizia float(2) not null check (costi_di_pulizia >= 0),
	tipo_alloggio varchar(19) not null check (tipo_alloggio like 'intero appartamento' or 
											  tipo_alloggio like 'stanza singola' or 
											  tipo_alloggio like 'stanza condivisa'),
	host varchar(50),
	constraint Alloggio_PK primary key(codice_alloggio),
	constraint Host_FK_Utente foreign key(host) references Host(utente) on update cascade on delete cascade
);

create table Foto (
	immagine bytea,
	alloggio varchar(15),
	constraint Foto_PK primary key(immagine),
	constraint Foto_FK_Alloggio foreign key(alloggio) references Alloggio(codice_alloggio) on update cascade on delete cascade
);

create table Servizio (
	nome varchar(30),
	constraint Servizio_PK primary key(nome)
);

create table Telefono (
	numero varchar(15),
	utente varchar(50),
	constraint Telefono_PK primary key(numero),
	constraint Telefono_FK_Utente foreign key(utente) references Utente(email) on update cascade on delete cascade
);

create table Prenotazione (
	id_prenotazione varchar(10),
	data_inizio date not null check (data_inizio < data_fine),
	data_fine date not null check (data_fine > data_inizio),
	numero_ospiti smallint default 0 not null check (numero_ospiti >= 0),
	costo_totale float(2) not null check (costo_totale >= 0),
	metodo_di_pagamento varchar(16) not null check (metodo_di_pagamento like 'carta di credito' or
												    metodo_di_pagamento like 'paypal' or 
												    metodo_di_pagamento like 'bancomat' or 
												    metodo_di_pagamento like 'satispay'),
	ospite varchar(50),
	alloggio varchar(15),
	constraint Prenotazione_PK primary key(id_prenotazione),
	constraint Prenotazione_FK_Ospite foreign key(ospite) references Ospite(utente) on update cascade on delete cascade,
	constraint Prenotazione_FK_Alloggio foreign key(alloggio) references Alloggio(codice_alloggio) on update cascade on delete cascade
);

create table PrenotazioneRifiutata (
	prenotazione varchar(10),
	constraint PrenotazioneRifiutata_PK primary key(prenotazione),
	constraint PrenotazioneRifiutata_FK_Prenotazione foreign key(prenotazione) references Prenotazione(id_prenotazione) on update cascade on delete cascade
);

create table PrenotazioneConfermata (
	prenotazione varchar(10),
	constraint PrenotazioneConfermata_PK primary key(prenotazione),
	constraint PrenotazioneConfermata_FK_Prenotazione foreign key(prenotazione) references Prenotazione(id_prenotazione) on update cascade on delete cascade
);

create table PrenotazioneCancellata (
	prenotazione_confermata varchar(10),
	utente varchar(50),
	constraint PrenotazioneCancellata_PK primary key(prenotazione_confermata),
	constraint PrenotazioneCancellata_FK_PrenotazioneConfermata foreign key(prenotazione_confermata) references PrenotazioneConfermata(prenotazione) on update cascade on delete cascade,
	constraint PrenotazioneCancellata_FK_Utente foreign key(utente) references Utente(email) on update cascade on delete cascade
);

create table PrenotazioneAccettata (
	prenotazione_confermata varchar(10),
	constraint PrenotazioneAccetata_PK primary key(prenotazione_confermata),
	constraint PrenotazioneAccetata_FK_PrenotazioneConfermata foreign key(prenotazione_confermata) references PrenotazioneConfermata(prenotazione) on update cascade on delete cascade
);

create table Recensione (
	prenotazione_accettata varchar(10),
	visibilità boolean not null,
	constraint Recensione_PK primary key(prenotazione_accettata),
	constraint Recensione_FK_PrenotazioneAccettata foreign key(prenotazione_accettata) references PrenotazioneAccettata(prenotazione_confermata) on update cascade on delete cascade
);

create table RecensioneHost (
	recensione varchar(10),
    testo_ospite text not null,
	constraint RecensioneHost_PK primary key(recensione),
	constraint RecensioneHost_FK_Recensione foreign key(recensione) references Recensione(prenotazione_accettata) on update cascade on delete cascade
);

create table RecensioneOspite ( 
	recensione varchar(10),
	testo_host text not null,
	testo_alloggio text not null,
	constraint RecensioneOspite_PK primary key(recensione),
	constraint RecensioneOspite_FK_Recensione foreign key(recensione) references Recensione(prenotazione_accettata) on update cascade on delete cascade
);

create table Dimensione (
	tipo varchar(20),
	constraint Dimensione_PK primary key(tipo)
);

create table Preferenza (
	utente varchar(50),
	alloggio varchar(15),
	constraint Preferenza_PK primary key(utente, alloggio),
	constraint Preferenza_FK_Utente foreign key(utente) references Utente(email) on update cascade on delete cascade,
	constraint Preferenza_FK_Alloggio foreign key(alloggio) references Alloggio(codice_alloggio) on update cascade on delete cascade
);

create table Possiede (
	servizio varchar(30),
	alloggio varchar(15),
	constraint Possiede_PK primary key(servizio, alloggio),
	constraint Possiede_FK_Servizio foreign key(servizio) references Servizio(nome) on update cascade on delete cascade,
	constraint Possiede_FK_Alloggio foreign key(alloggio) references Alloggio(codice_alloggio) on update cascade on delete cascade
);

create table Ospitato (
	prenotazione varchar(10),
	ospite varchar(50),
	constraint Ospitato_PK primary key(prenotazione, ospite),
	constraint Ospitato_FK_Prenotazione foreign key(prenotazione) references Prenotazione(id_prenotazione) on update cascade on delete cascade,
	constraint Ospitato_FK_Ospite foreign key(ospite) references Ospite(utente) on update cascade on delete cascade
);

create table Valutazione (
	recensione_ospite varchar(10),
	dimensione varchar(20),
	punteggio smallint default 1 not null check (punteggio >= 1 and punteggio <= 5),
	constraint Valutazione_PK primary key(recensione_ospite, dimensione),
	constraint Valutazione_FK_RecensioneOspite foreign key(recensione_ospite) references RecensioneOspite(recensione) on update cascade on delete cascade,
	constraint Valutazione_FK_Dimensione foreign key(dimensione) references Dimensione(tipo) on update cascade on delete cascade
);

create table Commento (
	id_commento varchar(12),
	testo text not null,
	recensione varchar(10),
	utente varchar(50),
	constraint Commento_PK primary key(id_commento),
	constraint Commento_FK_Recensione foreign key(recensione) references Recensione(prenotazione_accettata) on update cascade on delete cascade,
	constraint Commento_FK_Utente foreign key(utente) references Utente(email) on update cascade on delete cascade
);

create table Risposta (
	commento varchar(12),
	utente varchar(50),
	testo text not null,
	constraint Risposta_PK primary key(commento, utente),
	constraint Risposta_FK_Commento foreign key(commento) references Commento(id_commento) on update cascade on delete cascade,
	constraint Risposta_FK_Utente foreign key(utente) references Utente(email) on update cascade on delete cascade
);

insert into Utente values ('samuele.perrotta@gmail.com', 'abc34de12gb34', 'Samuele', 'Perrotta', 'file.SamuelePerrotta.jpg', TRUE);
insert into Utente values ('anita.scanu@gmail.com', 'dfgby6', 'Anita', 'Scanu', 'file.AnitaScanu.jpg', TRUE);
insert into Utente values ('stefano.pittavino@libero.com', 'fhgb567', 'Stefano', 'Pittavino', 'file.StefanoPittavino.jpg', TRUE);
insert into Utente values ('mario.porri@gmail.com', 'abcdethb123664', 'Mario', 'Porri', FALSE);
insert into Utente values ('federica.marani@yahoo.com', 'afbcdetsh128934', 'Federica', 'Marani', FALSE);

insert into Ospite values ('samuele.perrotta@gmail.com');
insert into Ospite values ('anita.scanu@gmail.com');
insert into Ospite values ('stefano.pittavino@libero.com');
insert into Ospite values ('federica.marani@yahoo.com');

insert into Host values ('samuele.perrotta@gmail.com', TRUE);
insert into Host values ('anita.scanu@gmail.com', FALSE);
insert into Host values ('federica.marani@yahoo.com', TRUE);
insert into Host values ('mario.porri@gmail.com', FALSE);

insert into Telefono values ('392 0875692', 'samuele.perrotta@gmail.com');
insert into Telefono values ('390 4568265', 'samuele.perrotta@gmail.com');
insert into Telefono values ('392 0025874', 'anita.scanu@gmail.com');
insert into Telefono values ('347 7893215', 'stefano.pittavino@libero.com');
insert into Telefono values ('333 1754787', 'stefano.pittavino@libero.com');
insert into Telefono values ('392 7412589', 'mario.porri@gmail.com');
insert into Telefono values ('391 4565633', 'mario.porri@gmail.com');
insert into Telefono values ('333 4883210', 'mario.porri@gmail.com');
insert into Telefono values ('333 4787744', 'federica.marani@yahoo.com');

insert into Dimensione values ('pulizia');
insert into Dimensione values ('precisione');
insert into Dimensione values ('comunicazione');
insert into Dimensione values ('posizione');
insert into Dimensione values ('check-in');
insert into Dimensione values ('qualità/prezzo');

insert into Alloggio values ('as120801', 'via Italia', 45, 'Biella', 13900, 'Casa blu', 'Piccola casa in centro Biella', 64, 3, '10:00:00', '11:00:00', 4.34, 56, 6, 'intero appartamento', 'samuele.perrotta@gmail.com');
insert into Alloggio values ('ad231024', 'corso Bernardino Telesio', 26, 'Torino', 10094, 'Stanza Aurora', 'Ampia stanza con balcone', 28, 1, '9:30:00', '10:00:00', 4.67, 223, 10, 'stanza singola', 'anita.scanu@gmail.com');
insert into Alloggio values ('gt212234', 'via dei Mille', 77, 'Bologna', 10121, 'Appartamento Garibaldi', 'Appartamento luminoso al 5° piano', 53, 2, '10:00:00', '12:00:00', 4.77, 128, 12, 'intero appartamento', 'federica.marani@yahoo.com');
insert into Alloggio values ('ui124311', 'Ladbroke Grove', 123, 'Londra', 23111, 'Stanza rosa', 'Letto in dormitorio femminile', 40, 2, '9:30:00', '18:30:00', 4.23, 28, 8, 'stanza condivisa', 'mario.porri@gmail.com');
insert into Alloggio values ('er977473', 'via Umberto II', 298, 'Milano', 20068, 'Stanza condivisa - centro', 'Stanza con letto a una piazza e mezza', 72, 1, '11:00:00', '11:00:00', 4.33, 112, 6, 'stanza singola', 'anita.scanu@gmail.com');

insert into Servizio values ('Wi-fi');
insert into Servizio values ('Aria condizionata');
insert into Servizio values ('Cucina');
insert into Servizio values ('Lavatrice');
insert into Servizio values ('Parcheggio');
insert into Servizio values ('Riscaldamento');
insert into Servizio values ('TV');
insert into Servizio values ('Piscina');

insert into Foto values ('file.fotocucina123.jpeg', 'as120801');
insert into Foto values ('file.fotocameraletto123.jpeg', 'as120801');
insert into Foto values ('file.fotosoggiorno123.jpeg', 'as120801');
insert into Foto values ('file.foto_stanza.png', 'ad231024');
insert into Foto values ('file.immagine_cameraletto.png', 'gt212234');
insert into Foto values ('file.immagine_soggiorno.png', 'gt212234');
insert into Foto values ('file.photo_cameraletto.png', 'ui124311');
insert into Foto values ('file.stanza_condivisa.png', 'er977473');

insert into Prenotazione values ('dyd65847', '2019\05\21', '2019\05\31', 3, 654.41, 'paypal', 'samuele.perrotta@gmail.com', 'as120801');
insert into Prenotazione values ('rrt65489', '2020\08\10', '2020\09\15', 0, 522, 'carta di credito', 'stefano.pittavino@libero.com', 'gt212234');
insert into Prenotazione values ('hhh45982', '2017\12\03', '2017\12\27', 1, 456.23, 'paypal', 'anita.scanu@gmail.com', 'er977473');
insert into Prenotazione values ('ejk45656', '2022\06\15', '2022\06\30', 5, 1223.78, 'bancomat', 'stefano.pittavino@libero.com', 'ad231024');
insert into Prenotazione values ('wih01789', '2020\01\01', '2020\01\31', 1, 458, 'satispay', 'federica.marani@yahoo.com', 'ad231024');

insert into PrenotazioneRifiutata values ('hhh45982');

insert into PrenotazioneConfermata values ('dyd65847');
insert into PrenotazioneConfermata values ('rrt65489');
insert into PrenotazioneConfermata values ('ejk45656');
insert into PrenotazioneConfermata values ('wih01789');

insert into PrenotazioneCancellata values ('dyd65847', 'samuele.perrotta@gmail.com');

insert into PrenotazioneAccettata values ('rrt65489');
insert into PrenotazioneAccettata values ('ejk45656');
insert into PrenotazioneAccettata values ('wih01789');

insert into Possiede values ('Wi-fi','as120801');
insert into Possiede values ('Riscaldamento','as120801');
insert into Possiede values ('TV','as120801');
insert into Possiede values ('Lavatrice','as120801');
insert into Possiede values ('Cucina','as120801');
insert into Possiede values ('Riscaldamento','ad231024');
insert into Possiede values ('TV','ad231024');
insert into Possiede values ('Wi-fi','ad231024');
insert into Possiede values ('Cucina','ad231024');
insert into Possiede values ('Aria condizionata','gt212234');
insert into Possiede values ('Parcheggio','gt212234');
insert into Possiede values ('TV','gt212234');
insert into Possiede values ('Wi-fi','gt212234');
insert into Possiede values ('Aria condizionata','ui124311');
insert into Possiede values ('Riscaldamento','ui124311');
insert into Possiede values ('Cucina','er977473');
insert into Possiede values ('Wi-fi','er977473');
insert into Possiede values ('Aria condizionata','er977473');
insert into Possiede values ('Piscina','er977473');

insert into Preferenza values ('anita.scanu@gmail.com','as120801');
insert into Preferenza values ('anita.scanu@gmail.com','ui124311');
insert into Preferenza values ('samuele.perrotta@gmail.com','ad231024');
insert into Preferenza values ('samuele.perrotta@gmail.com','ui124311');
insert into Preferenza values ('stefano.pittavino@libero.com','as120801');
insert into Preferenza values ('stefano.pittavino@libero.com','ui124311');
insert into Preferenza values ('federica.marani@yahoo.com','er977473');
insert into Preferenza values ('federica.marani@yahoo.com','as120801');

insert into Ospitato values ('dyd65847','anita.scanu@gmail.com');
insert into Ospitato values ('dyd65847','stefano.pittavino@libero.com');
insert into Ospitato values ('rrt65489','federica.marani@yahoo.com');

insert into Recensione values ('rrt65489', FALSE);
insert into Recensione values ('ejk45656', FALSE);
insert into Recensione values ('wih01789', TRUE);

insert into RecensioneHost values ('rrt65489', 'Ospite molto educato e gentile.');
insert into RecensioneHost values ('ejk45656', 'Ospiti scortesi e insolenti!');
insert into RecensioneHost values ('wih01789', 'Ospite gentile e di buone maniere.');

insert into RecensioneOspite values ('rrt65489', 'Host molto gentile e disponibile.', 'Struttura molto bella e qualità/prezzo ottimo, la consiglio!');
insert into RecensioneOspite values ('ejk45656', 'Scortesia e maleducazione da parte della proprietaria', 'Alloggio tenuto male e trascurato, a mai più.');
insert into RecensioneOspite values ('wih01789', 'Gentilezza della proprietaria top.', 
									 'Ottima posizione, ci riverrò sicuramente. La stanza era molto calda 
									  e faceva caldo, ma peccato che non si possa controllare la temperatura della caldaia (forse non sono riuscita a trovarla)');

insert into Valutazione values ('rrt65489', 'pulizia', 4);
insert into Valutazione values ('rrt65489', 'precisione', 5);
insert into Valutazione values ('rrt65489', 'comunicazione', 5);
insert into Valutazione values ('rrt65489', 'posizione', 4);
insert into Valutazione values ('rrt65489', 'check-in', 5);
insert into Valutazione values ('rrt65489', 'qualità/prezzo', 5);
insert into Valutazione values ('ejk45656', 'pulizia', 1);
insert into Valutazione values ('ejk45656', 'precisione', 1);
insert into Valutazione values ('ejk45656', 'comunicazione', 1);
insert into Valutazione values ('ejk45656', 'posizione', 2);
insert into Valutazione values ('ejk45656', 'check-in', 2);
insert into Valutazione values ('ejk45656', 'qualità/prezzo', 1);
insert into Valutazione values ('wih01789', 'pulizia', 3);
insert into Valutazione values ('wih01789', 'precisione', 5);
insert into Valutazione values ('wih01789', 'comunicazione', 5);
insert into Valutazione values ('wih01789', 'posizione', 5);
insert into Valutazione values ('wih01789', 'check-in', 4);
insert into Valutazione values ('wih01789', 'qualità/prezzo', 4);

insert into Commento values ('sdc3213', 'Grazie per il tuo soggiorno', 'rrt65489', 'federica.marani@yahoo.com');
insert into Commento values ('kfj3210', 'Ciao. Ti avrei informato subito se avessi avuto una richiesta, ma mi dispiace che tu 
							 possa essere stato a disagio. Quando ci visiterai la prossima volta, se hai domande, ti preghiamo 
							 di comunicarcelo e ti risponderemo gentilmente.', 'wih01789', 'anita.scanu@gmail.com');
insert into Commento values ('flr8512', 'Anche io ho riscontrato lo stesso problema', 'wih01789', 'samuele.perrotta@gmail.com');

insert into Risposta values ('kfj3210', 'federica.marani@yahoo.com', 'Perfetto, grazie mille, la prossima volta le farò sapere!!');
insert into Risposta values ('flr8512', 'anita.scanu@gmail.com', 'Mi spiace del disagio, la prossima volta non esiti a farci domande');

delete from Alloggio where comune like 'Bologna';
	/*
	  Cancellando la tupla nella tabella Alloggio, che ha come valore dell'attributo
	  comune 'Bologna', vengono cancellate di conseguenza tutte le tuple nel database
	  ad esso collegate con vincoli d'integrità referenziale perchè abbiamo aggiunto
	  la clausola on delete cascade a tutti i vincoli di chiave esterna.
	*/
	
delete from Foto where alloggio like 'as120801';
	/*
	  Cancellando la tupla nella tabella Foto, che ha come valore dell'attributo
	  alloggio 'as120801', non vengono cancellate altre tuple nel database perchè
	  nessun attributo ha un vincolo d'integrità referenziale con la tabella Foto.
	*/
	
update Utente
set email = 'm.por@libero.com'
where email like 'mario.porri@gmail.com';
	/*
	  Aggiornando l'attributo email nella tabella Utente, vengono aggiornate di conseguenza
	  tutte le email delle tabelle esterne che hanno un vincolo d'integrità referenziale con 
	  l'attributo email in Utente per via della clausola on update cascade.
	*/
	
update Valutazione
set punteggio = 5
where recensione_ospite like 'rrt65489' and dimensione like 'pulizia' and punteggio = 4;
	/*
	  Aggiornando l'attributo punteggio nella tabella Valutazione, non vengono aggiornati altri valori
	  perchè nessun'altra tabella ha un vincolo d'integrità referenziale con un attributo di Valutazione.
	*/