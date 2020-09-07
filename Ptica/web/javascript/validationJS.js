/* Projekat : Ptica
 * Autor : Ingrid Farkaš
 * validationJS.js: funkcije korišćene za validaciju
 */

CELOIME_VR = 'true'; // da li input field za celo ime sadrži samo slova( i apostrof )
IME_VR = 'true'; // da li input field za ime sadrži samo slova( i apostrof )
PREZIME_VR = 'true'; // da li input field za prezime sadrži samo slova( i apostrof )
ISBN_VR = 'true'; // da li ISBN input field sadrži samo cifre
CENA_VR = 'true'; // da li input field za cenu sadrži samo cifre( i tačku i zarez )
STR_VR = 'true'; // da li input field za broj stranica sadrži samo cifre
GODIZDAV_VR = 'true'; // da li input field za godinu izdavanja sadrži samo cifre

// postaviVr: zavisno od vrsta_broja, postavlja jednu od variabli na vrednost vrednost
function postaviVr(vrsta_broja, vrednost) {
    if (vrsta_broja == 'je_isbn') {
        ISBN_VR  = vrednost;
    } else if (vrsta_broja == 'je_brstr') {
        STR_VR = vrednost;
    } else if (vrsta_broja == 'je_cena') {
        CENA_VR = vrednost;
    } else if (vrsta_broja == 'je_godizd') {
        GODIZDAV_VR = vrednost;
    }
}

// broj: prikazuje poruku( u polje_poruka) ako je korisnik uneo vrednost koja nije broj( u input field za nazivom input_polje )
// ako je karakteri true, broj može da sadrži % ili _
// ako je dec_tacka true, broj može da sadrži .
// vrsta_broja - da li je unos u input field-u isbn, cena, broj stranica ili godina
// formid: id forme
function broj(formid, input_polje, vrsta_broja, polje_poruka, karakteri, dec_tacka) {
    var broj_polje;
    var regex;
   
    broj_polje = document.getElementById(input_polje).value;  
    if (karakteri && dec_tacka) { // %, _ ili . može da se unese u input field( pored cifara )
        regex = /^[0-9\x25\x5F\x2E]+$/;
    } else if (dec_tacka) {
        regex = /^[0-9\x2E]+$/;
    } else if (karakteri) { // % or _ može da se unese u input field ( pored cifara )
        regex = /^[0-9\x25\x5F]+$/;
    } else {
        regex = /^[0-9]+$/;
    }
    if (broj_polje != '') {
        // ako vrednost unesena za isbn nije broj ( ako je karakteri true, broj može da sadrži % ili _ )
        if (!regex.test(broj_polje)) {
            if (karakteri && dec_tacka) { // %, _, . can be entered in the input field ( beside digits )
                document.getElementById(polje_poruka).innerHTML = "Ovo polje može da sadrži cifre (džoker znakove i decimalnu tačku)"; 
            } else if (dec_tacka) { 
                document.getElementById(polje_poruka).innerHTML = "Ovo polje može da sadrži cifre (i decimalnu tačku)"; // prikaži poruku 
            } else if (karakteri) {
                document.getElementById(polje_poruka).innerHTML = "Ovo polje može da sadrži cifre (i džoker znakove)"; 
            } else {
                document.getElementById(polje_poruka).innerHTML = "Ovo polje može da sadrži cifre."; 
            }
            postaviVr( vrsta_broja, 'false' );
        } else {
            postaviVr( vrsta_broja, 'true' );
            document.getElementById(polje_poruka).innerHTML = ""; // prikaži poruku 
        }
    } else {
        postaviVr( vrsta_broja, 'true' );
        document.getElementById(polje_poruka).innerHTML = ""; // prikaži poruku 
    }
    
}

// dalijeCena: prikazuje poruku( u polje_poruka ) ako je korisnik uneo vrednost koja nije cena( u input field za nazivom input_polje )
// vrsta_broja - da li je unos u input field-u isbn, cena, broj stranica ili godina
// formid: id forme
function daLiJeCena(formid, input_polje, vrsta_broja, polje_poruka) {
    var broj_polje;
    var regex;
    
    broj_polje = document.getElementById(input_polje).value;
    regex = /^[0-9\x2C\x2E]+$/; // može da sadrži cifre, zarez i decimalnu tačku
    if (broj_polje.length > 9) {
        document.getElementById(polje_poruka).innerHTML = "Ovo polje može da sadrži cenu manju ili jednaku 99.999,99"; 
        postaviVr(vrsta_broja, 'false');
    } else {
        if (broj_polje != '') {
            // ako vrednost unesena za isbn nije broj
            if (!regex.test(broj_polje)) { 
                document.getElementById(polje_poruka).innerHTML = "Ovo polje može da sadrži cenu ( cifre, tačku i zarez )"; 
                postaviVr(vrsta_broja, 'false');
            } else {
                postaviVr(vrsta_broja, 'true');
                document.getElementById(polje_poruka).innerHTML = ""; // prikaži poruku  
            }
        } else {
            postaviVr( vrsta_broja, 'true' );
            document.getElementById(polje_poruka).innerHTML = ""; // prikaži poruku  
        }
    }
}

// postaviVrImena - zavisno da li je korisnik uneo celo ime, ime ili prezime postavi vrednost odgovarajuće varijable
// vrsta_imena: 'celoime' ( korisnik uneo celo ime ), 'ime', 'prezime' 
// vrednost: 'true' or 'false'
function postaviVrImena(vrsta_imena, vrednost) {
    switch (vrsta_imena) { // zavisno da li je korisnik uneo celo ime, ime ili prezime postavi vrednost odgovarajuće varijable
        case 'celoime':
            CELOIME_VR = vrednost;
            break;
        case 'ime':
            IME_VR = vrednost;
            break;
        case 'prezime':
            PREZIME_VR = vrednost;
            break;
        default:
    }
}

// slova: proverava da li su u input_polje unesena samo slova( ili apostrofi, zarezi, -, prazno mesto, %, _ ).
// ako je nešto drugo uneseno u poruka_span se prikazuje poruka
// kada korisnik ispravi grešku, ispod polja se više ne prikazuje poruka
// obavezno - da li je popunjavanje polja obavezno 
// vrsta_imena - 'celoime'( korisnik je uneo celo ime ), 'ime', 'prezime'
// karakteri - da li se džoker znakovi mogu pojaviti u polju
function slova(input_polje, poruka_span, vrsta_imena, karakteri, obavezno) {
    var regex;
    
    if (karakteri) { // % ili _ može da se unese u polje( pored slova, apostrofa, zareza, -, praznog mesta )
        regex = /^[a-zA-Z\x27\x20\x2C\x2D\x25\x5F]+$/;
    } else {
        regex = /^[a-zA-Z\x27\x20\x2C\x2D]+$/;
    }
    if (!input_polje.value == '') {
        if (!regex.test(input_polje.value)) { // ako je korisnik uneo karaktere koja nisu slova( u polje )
            if (karakteri)
                poruka_span.innerHTML = "Ovo polje može da sadrži slova, prazno mesto, džoker znakove i znakove ,'- ";
            else
                poruka_span.innerHTML = "Ovo polje može da sadrži slova, prazno mesto, i znakove ,'- ";
            postaviVrImena(vrsta_imena, 'false');
        } else { // ako je korisnik uneo karaktere koja su slova( u polje )
            postaviVrImena(vrsta_imena, 'true');
            poruka_span.innerHTML = "";
        }
    } else {
        if (obavezno == 'true') {
            postaviVrImena(vrsta_imena, 'false');
            poruka_span.innerHTML = " ";
        } else {
            postaviVrImena(vrsta_imena, 'true');
            CELOIME_VR = 'true';
            poruka_span.innerHTML = "";
        }
    }
}

// proveriF: ako je validacija uspešna onda vraća TRUE inače vraća FALSE
function proveriF(){
    if ((CELOIME_VR === 'true') && (IME_VR === 'true') && (PREZIME_VR === 'true') && (ISBN_VR === 'true') && (CENA_VR === 'true') && (STR_VR === 'true') && (GODIZDAV_VR === 'true')) { 
        return true;
    } else {
        return false;
    }
}

