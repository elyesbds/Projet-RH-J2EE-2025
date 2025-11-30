package filters;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Filtre pour vérifier l'authentification
 * Bloque l'accès aux pages si l'utilisateur n'est pas connecté
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();

        // Pages publiques accessibles sans connexion
        // ATTENTION : "/" et "/index.jsp" ne sont PAS publiques, il faut être connecté !
        boolean isPublicPage = path.equals(contextPath + "/login") ||
                path.endsWith(".css") ||
                path.endsWith(".js") ||
                path.endsWith(".png") ||
                path.endsWith(".jpg") ||
                path.endsWith(".jpeg") ||
                path.endsWith(".gif");

        // Vérifier si l'utilisateur est connecté
        HttpSession session = httpRequest.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);

        if (isPublicPage || isLoggedIn) {
            // Autoriser l'accès
            chain.doFilter(request, response);
        } else {
            // Rediriger vers la page de login
            httpResponse.sendRedirect(contextPath + "/login");
        }
    }
}