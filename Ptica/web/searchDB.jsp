<%-- 
    Dokument  : searchDB.jsp se poziva iz search_form.jsp
    Formiran  : 18-Sep-2018, 00:54:05
    Autor     : Ingrid Farkaš
    Projekat  : Ptica
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page import="connection.ConnectionManager"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.lang.CharSequence"%>
<%@page import="miscellaneous.PticaMetodi"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="css/templatecss.css" type="text/css" rel="stylesheet"/>
        <title>Ptica - Pretraga knjiga</title>
        <%@ include file="header.jsp"%>
    </head>
    
    <body>
        <%!
            // sadr_dzoker vraća true ako str sadrži jedan od znakova % ili _ ( džoker znakovi ). Inače vraća false.
            boolean sadr_dzoker(String str) {
            CharSequence podvlaka = "_";
            CharSequence procenat = "%";
            // da li string sadrži _ ili %
            if ((str.contains(podvlaka)) || (str.contains(procenat)))
                return true;
            else
                return false;
            }
        %>
        <!-- dodavanje novog reda u Bootstrap grid: klasa belapoz postavlja pozadinu u belu boju -->
        <div class="belapoz">
            <div class="row"> 
                <div class="col-lg-6 col-md-6"> 
                    <br /><br />
                    <div> <!-- slika-centar postavlja sliku u sredinu ( horizontalno ), img-fluid je za responsivan image -->
                        <img src="images/books.png" class="img-fluid slika-centar" alt="slika sa knjigama" title="slika sa knjigama"> 
                    </div>
                </div>
                       
                <div class="col-lg-5 col-md-5"> 
                    <div class="container">
                        <div class="row"> <!-- dodavanje novog reda u Bootstrap grid -->
                            <div class="col">
                                &nbsp; &nbsp;
                                <br/>
                                <h3 class="text-info">Pretraga knjiga</h3><br/>
                                
                                <%
                                    boolean pronKnjige = false; // da li su pronađene knjige prilikom Pretrage knjiga 
                                    boolean newsl = false; // da li se neposredno prethodno korisnik prijavio na Newsletter
                                    HttpSession hSesija = PticaMetodi.vratiSesiju(request);
                                    // varijabla sessije je postavljena na true u subscrres_content.jsp ( ako se korisnik prijavio na Newsletter )
                                    if (PticaMetodi.varSesijePostoji(hSesija, "newsletter")) {
                                        // ime veb stranice koja je prikazana pre ove stranice
                                        newsl = Boolean.valueOf(String.valueOf(hSesija.getAttribute("newsletter")));
                                        hSesija.setAttribute("newsletter", "false"); // postavljanje varijable sesije na inicijalnu vrednost
                                    } 
                                    hSesija.setAttribute("ime_vebstr", "searchDB.jsp");
                                
                                    try { 
                                        String f_naslov = "";  // naslov unesen ( sa stanice search_form.jsp )
                                        String f_autor = "";
                                        String f_isbn = "";
                                        String f_cena = "";
                                        String f_sortirajpo = "";
                                        String f_zanr = "";
                                        String f_godizd = ""; // godina izdanja ( sa stanice search_form.jsp ) 
                                
                                        // korisnik se neposredno prethodno prijavio na Newsletter - treba da pročitam vrednosti iz forme
                                        if (newsl) { 
                                            // pročitaj i resetuj varijable sesije
                                            f_naslov = PticaMetodi.citajVarSesije(hSesija, "input0"); // naslov 
                                            f_autor = PticaMetodi.citajVarSesije(hSesija, "input1"); // autor
                                            f_isbn = PticaMetodi.citajVarSesije(hSesija, "input2"); // isbn
                                            f_cena = PticaMetodi.citajVarSesije(hSesija, "input3"); // cena
                                            f_sortirajpo = PticaMetodi.citajVarSesije(hSesija, "input4"); // kriterijum za sortiranje
                                            f_zanr = PticaMetodi.citajVarSesije(hSesija, "input5"); // žanr             
                                            f_godizd = PticaMetodi.citajVarSesije(hSesija, "input6"); // godina izdavanja

                                            // postavlja varijable sesije ( čija imena počinju sa input ) na ""
                                            PticaMetodi.postaviNaPrazno(hSesija);
                                        }
                                    
                                        if (!newsl) { // korisnik prikazuje ovu veb stranicu BEZ prijave na Newsletter
                                            f_naslov = request.getParameter("naslov"); // naslov koji je korisnik uneo
                                            f_autor = request.getParameter("autor"); 
                                            f_isbn = request.getParameter("isbn"); 
                                            f_sortirajpo = request.getParameter("sortirajpo"); 
                                            f_zanr = request.getParameter("zanr"); // žanr
                                            f_cena = request.getParameter("raspon_cena"); // raspon cene
                                            f_godizd = request.getParameter("god_izdavanja"); // godina izdavanja
                                    
                                            // postavlja varijable sesije ( čija imena počinju sa input ) na ""
                                            PticaMetodi.postaviNaPrazno(hSesija);
                                        }
                                    
                                        // izbrisiPrazno: uklanja prazan prostor sa početka i kraja stringa i zamenjuje 2 ili više prazna mesta ( unutar stringa )
                                        // sa jednim praznim mestom
                                        f_naslov = PticaMetodi.izbrisiPrazno(f_naslov);
                                        f_autor = PticaMetodi.izbrisiPrazno(f_autor);
                                        f_isbn = PticaMetodi.izbrisiPrazno(f_isbn);
                                        f_godizd = PticaMetodi.izbrisiPrazno(f_godizd);
                                    %>  
                                    <%
                                        Connection con = ConnectionManager.getConnection(); // povezivanje sa bazom  
                                        Statement stmt = con.createStatement();
                                    
                                        String sUpit = "select k.naslov, k.cena, k.isbn, k.god_izdavanja, k.opis, a.ime_autora from knjiga k, autor a where (k.br_autora = a.br_autora)";
                                    
                                        // ako je korisnik uneo naslov
                                        if (!(f_naslov.equalsIgnoreCase(""))) {
                                            // dKosuC : zamenjuje svaku pojavu \ sa \\\\ i svaku pojavu ' sa \\'
                                            f_naslov = PticaMetodi.dKosuC(f_naslov);
                                            // ako naslov sadrži ? ili _ tada dodajem Like 
                                            if (sadr_dzoker(f_naslov)){
                                                sUpit += " AND (k.naslov LIKE '" + f_naslov + "')";
                                            } else 
                                                sUpit += " AND (k.naslov='" + f_naslov + "')";
                                        }     
                                    
                                        // ako je korisnik uneo ime autora
                                        if (!(f_autor.equalsIgnoreCase(""))) {
                                            // dKosuC : zamenjuje svaku pojavu \ sa \\\\ i svaku pojavu ' sa \\'
                                            f_autor = PticaMetodi.dKosuC(f_autor);
                                            // ako autor sadrži ? ili _ tada dodajem Like 
                                            if (sadr_dzoker(f_autor))
                                                sUpit += " AND (a.ime_autora LIKE '" + f_autor + "')";
                                            else
                                                sUpit += " AND (a.ime_autora='" + f_autor + "')";
                                        }
                                    
                                        // ako je korisnik uneo isbn
                                        if (!(f_isbn.equalsIgnoreCase(""))) {
                                            // ako isbn sadrži ? ili _ tada dodajem Like 
                                            if (sadr_dzoker(f_isbn))
                                                sUpit += " AND (k.isbn LIKE '" + f_isbn + "')";
                                            else
                                                sUpit += " AND (k.isbn='" + f_isbn + "')";
                                        }
                                    
                                        String tempStr; // koristi se za formiranje upita
                                        if (f_zanr.equalsIgnoreCase("svi"))
                                            tempStr="";
                                        else {
                                            tempStr = f_zanr;
                                        }
                                    
                                        // dodaj upitu da li je žanr jednak tempStr
                                        if (!(tempStr.equalsIgnoreCase(""))) {
                                            sUpit += " AND ((k.žanr='" + tempStr + "')";
                                            sUpit += " OR (k.žanr='svi'))";
                                        }
                                        
                                        tempStr="";
                                        // da li je cena < 500 
                                        if (f_cena.equalsIgnoreCase("manje500"))
                                            tempStr = "< 500"; 
                                        // da li je cena između 500 i 1000 
                                        else if (f_cena.equalsIgnoreCase("izm500-1000"))
                                            tempStr = "BETWEEN 500 AND 1000";
                                        // da li je cena između 1001 i 2000 
                                        else if (f_cena.equalsIgnoreCase("izm1001-2000"))
                                            tempStr = "BETWEEN 1001 AND 2000";
                                        // da li je cena između 2001 i 5000 
                                        else if (f_cena.equalsIgnoreCase("izm2001-5000"))
                                            tempStr = "BETWEEN 2001 AND 5000";
                                        // da li je cena > 500
                                        if (f_cena.equalsIgnoreCase("iznad5000"))
                                            tempStr = "> 5000";
                                    
                                        // dodaj upitu da li je cena u odgovarajućem intervalu
                                        if (!(tempStr.equalsIgnoreCase(""))) 
                                            sUpit += " AND (k.cena " + tempStr + " )";

                                        // da li je korisnik uneo godinu izdavanja
                                        if (!(f_godizd.equalsIgnoreCase(""))) {
                                            // ako godina izdavanja sadrži ? ili _ tada dodajem Like 
                                            if (sadr_dzoker(f_godizd))
                                                sUpit += " AND (k.god_izdavanja LIKE '" + f_godizd + "')";
                                            else
                                                sUpit += " AND (k.god_izdavanja='" + f_godizd + "')";
                                        }
                                    
                                        // sortiraj slogove ( opadajuće ili rastuće ) zavisno od izbora korisnika
                                        sUpit += " ORDER BY k.cena "; 

                                        if (f_sortirajpo.equalsIgnoreCase("nisko")) 
                                            sUpit += "ASC";
                                        else
                                            sUpit += "DESC";
                                        sUpit += ";";
                                    
                                        // izvrši upit
                                        ResultSet rs = stmt.executeQuery(sUpit); 

                                        // posle klika na dugme se prikazuje search_page.jsp
                                        out.println("<form action=\"search_page.jsp\" method=\"post\">");
                                    
                                        if (!(rs.next())) { // nema pronađenih knjiga
                                            out.println("<br /><br /><br />");
                                            out.println("Za izabrane kriterijume <span class=\"text-warning\">nije pronađena nijedna knjiga!</span>");
                                            out.println("<br /><br /><br /><br /><br />");
                                        } else {
                                            pronKnjige = true;
                                            out.println("Sledeće knjige ispunjavaju zadate kriterijume: ");
                                            out.println("<br /><br />");
                                            // prikaži rezultat pretrage u obliku neuređene liste
                                            out.print("<ul>");
                                            // ako rezultat pretrage sadrži sledeći red
                                            do {
                                                // pročitaj naslov
                                                String sNaslov = rs.getString("naslov");
                                                // pročitaj ime autora
                                                String sAutor = rs.getString("ime_autora");
                                                // pročitaj cenu
                                                String sCena = rs.getString("cena");
                                                // pročitaj ISBN
                                                String sISBN = rs.getString("isbn");
                                                // prikaži naslov, autor i cenu
                                                String opis = rs.getString("opis");
                                                out.print("<li><b>" + sNaslov + "</b> (autor: " + sAutor + ")" ); 
                                                // ako postoji cena : prikaži je
                                                if (sCena != null) {
                                                    // u bazi cena je u obliku 99999.99; na obrazcu cena treba da bude u obliku 99.999,99
                                                    sCena = sCena.replace('.',','); // zameni decimalnu . sa ,
                                                    sCena = PticaMetodi.dodajTacku(sCena); // dodajem tačku u cenu iza hiljadu dinara 
                                                    out.print(" <b>cena: </b>" + sCena + " RSD");
                                                }
                                                
                                                // ako postoji Isbn : prikaži ga
                                                if (sISBN != null) {
                                                    out.print("<br /><b>" + "Isbn: </b>" + sISBN );
                                                }
                                                
                                                // ako postoji opis : prikaži ga
                                                if (opis != null) {
                                                    out.print("<br /><b>" + "Opis: </b>" + opis );
                                                }
                                                
                                                out.print("</li>");
                                            } while(rs.next());

                                            out.print("</ul>");
                                        }
                                        out.print("<br />");
                                        // dodajem dugme obracu; btn-sm se koristi za manju ( užu ) veličinu kontrole -->
                                        out.print("<button type=\"submit\" class=\"btn btn-info btn-sm\">Pretraga knjiga</button>");
                                        out.println("</form>");
                                    } catch(Exception e) {
                                        String sPoruka = "GR_PRETR"; // koristi se za prosleđivanje poruke
                                        String sNaslov = "Greška"; // koristi se za prosleđivanje naslova
                                        hSesija.setAttribute("ime_izvora", "Pretraga knjiga"); // naziv veb strane na kojoj sam sada
                                        hSesija.setAttribute("naslov", sNaslov); 
                                        hSesija.setAttribute("poruka", sPoruka); 
                                        response.sendRedirect("error_succ.jsp"); // preusmeravanje na error_succ.jsp  
                                    }
                                %>

                            </div> <!-- završetak class="col" -->
                        </div> <!-- završetak class="row" --> 
                    </div> <!-- završetak class="container" -->
                </div> <!-- završetak class="col-lg-5 col-md-5" -->
            </div> <!-- završetak class="row" -->
        </div> <!-- završetak class="belapoz" -->
         
        <% if (pronKnjige) { // ako postoje knjige koje su pronađene ( i prikazane ) kao rezultat upita
        %>
        
            <div class="belapoz">
                <div class="col">
                    &nbsp; &nbsp;
                </div>
            </div> 
    
        <%
           }
        %>
        
        <!-- dodajem novi red u Bootstrap grid; klasa belapoz: za postavljanje pozadine u belu boju -->
        <div class="belapoz">
            <div class="col">
                &nbsp; &nbsp;
            </div>
        </div> 
          
        <%@ include file="footer.jsp"%>
    </body>
</html>
