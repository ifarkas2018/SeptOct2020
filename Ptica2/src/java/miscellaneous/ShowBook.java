/*
 * autor    : Ingrid Farkaš
 * projekat : Ptica
 * ShowBook.java : poziva se iz index_content.jsp kada korisnik klikne na jedan od slika knjiga 
 */
package miscellaneous;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author user
 */
public class ShowBook extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ShowBook</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ShowBook at " + request.getContextPath() + "</h1>");
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
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            HttpSession hSesija2 = PticaMetodi.vratiSesiju(request);
            
            int i = 0;
            Cookie[] kolacici = request.getCookies(); // niz koji sadrži kolačiće
            int duz_kolacici = kolacici.length;
            boolean nadjen = false; // da li je pronađen kolačić indeks_knjige  

            // prolazim kroz kolačiće dok kolačić sa imenom indeks_knjige nije pronađen 
            while (i < duz_kolacici && !nadjen) {
                Cookie kolacic = kolacici[i];
                // ime kolačića
                String kolacic_ime = kolacic.getName();

                // da li je ime kolačića indeks_knjige
                boolean je_knjiga_indeks = kolacic_ime.equalsIgnoreCase("indeks_knjige");
                if (je_knjiga_indeks) {
                   String kolacic_vr = kolacic.getValue();
                   // postavljanje vrednosti varijable sesije indeks_knjige na kolacic_vr
                   hSesija2.setAttribute(kolacic_ime, kolacic_vr);
                   nadjen = true;
                }
                i++;
            }
            
            response.sendRedirect("home_book.jsp"); // preusmeravanje na home_book.jsp 
        }
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
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
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
