/*
 * Export do widget de navegação inferior global para uso no Dashboard.
 * Este arquivo funciona como um atalho (barrel export) para expor a barra de
 * navegação inferior compartilhada (BottomNav) sem a necessidade de importar
 * diretamente o caminho absoluto da pasta compartilhada (shared) nos arquivos
 * locais do Dashboard.
 * 
 * Facilita a manutenção do código caso o local físico do BottomNav mude no futuro,
 * centralizando o mapeamento de importações.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */
library;

// Expõe publicamente apenas o BottomNav do pacote de componentes compartilhados da MesclaInvest
export 'package:mesclainvest/shared/widgets/bottom_nav.dart' show BottomNav;
