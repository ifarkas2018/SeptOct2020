/*
 * autor   : Ingrid Farkaš
 * projekat: Ptica
 * DodajServlet.java : kada korisnik klikne na dugme Dodaj knjigu (dodaj_obrazac.jsp) tada se ovaj servlet poziva
 */
package dodajservlet;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import miscellaneous.PticaMetodi;
import java.net.URLDecoder;

public class DodajServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */ 
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet DodajServlet</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet DodajServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        String sNaslov = "Nova knjiga"; // koristi se za prosleđivanje naslova u error_succ.jsp
        String sPoruka = ""; // za prosleđivanje poruke
        HttpSession hSesija = request.getSession();
        
        try {
            String f_izdavac = request.getParameter("izdavac"); // tekst unet u formi za izdavača
            f_izdavac = PticaMetodi.dekoder(f_izdavac); // dekodiranje izdavača (može da sadrži srpska slova)
            String f_autor = request.getParameter("autor"); // tekst unet u formi za autora
            f_autor = PticaMetodi.dekoder(f_autor); // dekodiranje autora (može da sadrži srpska slova)
            
            String f_naslov = request.getParameter("naslov"); // tekst unet u formi za naslov
            f_naslov = PticaMetodi.dekoder(f_naslov); // dekodiranje naslova (može da sadrži srpska slova)
        
            String f_isbn = request.getParameter("isbn"); // isbn 
            String f_cena = request.getParameter("cena"); // cena
            String f_strane = request.getParameter("strane"); // broj strana
            String f_zanr = request.getParameter("zanr"); // žanr
            String f_opis = request.getParameter("opis"); // opis knjige
            f_opis = PticaMetodi.dekoder(f_opis); // dekodiranje opisa (može da sadrži srpska slova)
            String f_gdizdav = request.getParameter("gd_izdav"); // godina izdavanja 
        
            f_cena = f_cena.replace(".", "");
            f_cena = f_cena.replace(",", "."); // tip podataka za cenu u bazi je float
        
            // izbrisiPrazno: uklanja prazni prostor sa početka i kraja stringa i zamenjuje 2 ili više praznih mesta sa jednim praznim mestom
            // unutar stringa
            f_naslov = PticaMetodi.izbrisiPrazno(f_naslov);
            f_autor = PticaMetodi.izbrisiPrazno(f_autor);
            f_isbn = PticaMetodi.izbrisiPrazno(f_isbn);
            f_cena = PticaMetodi.izbrisiPrazno(f_cena);
            f_strane = PticaMetodi.izbrisiPrazno(f_strane);
            f_opis = PticaMetodi.izbrisiPrazno(f_opis);
            f_izdavac = PticaMetodi.izbrisiPrazno(f_izdavac);
            f_gdizdav = PticaMetodi.izbrisiPrazno(f_gdizdav);
        
            // dKosuC: zamenjuje svaku pojavu \ sa \\\\ i zamenjuje svaku pojavu ' sa \\'
            f_naslov = PticaMetodi.dKosuC(f_naslov);
            f_autor = PticaMetodi.dKosuC(f_autor);
            f_opis = PticaMetodi.dKosuC(f_opis);
            f_izdavac = PticaMetodi.dKosuC(f_izdavac);
        
            // metod dodNovuKnj dodaje novu knjigu u tabelu knjiga (vraća String zavisno od poruke koju će error_succ.jsp prikazati)
            sPoruka = DodajDAO.dodNovuKnj(hSesija, f_naslov, f_autor, f_izdavac, f_isbn, f_cena, f_strane, f_zanr, f_opis, f_gdizdav);
       
            // zavisno od vrednosti koju je vratio metod dodNovuKnj određujem sNaslov
            if ((sPoruka.equals("GR_DODAJ")) || (sPoruka.equals("GR_NOVA_POST"))) {
                sNaslov = "Greška"; // koristi se za prosleđivanje naslova u JSP
            } else if (sPoruka.equals("USPEH_DOD")) {
                sNaslov = "Nova knjiga"; // koristi se za prosleđivanje naslova u JSP
            }
        
        } catch (Exception e) {
            // postavljanje vrednosti varijabli sesije
            sNaslov = "Greška"; // koristi se za prosleđivanje naslova u JSP
            sPoruka = "GR_DODAJ";
            hSesija.setAttribute("ime_izvora", "Nova knjiga"); // naziv veb strane na kojoj sam sada
            hSesija.setAttribute("poruka", sPoruka); 
            hSesija.setAttribute("naslov", sNaslov); 
            response.sendRedirect("error_succ.jsp"); // preusmeravanje na error_succ.jsp  
        }
        
        hSesija.setAttribute("ime_izvora", "Nova knjiga"); // naziv veb strane na kojoj sam sada
        hSesija.setAttribute("poruka", sPoruka); 
        hSesija.setAttribute("naslov", sNaslov); 
        response.sendRedirect("error_succ.jsp"); // preusmeravanje na error_succ.jsp 
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>
}
