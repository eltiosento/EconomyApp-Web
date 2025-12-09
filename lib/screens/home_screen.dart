import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/providers/auth_provider.dart';
//import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/providers/providers_utils_providers.dart';
import 'package:economy_app/providers/user_dto_provider.dart';
import 'package:economy_app/routes/app_routes.dart';
import 'package:economy_app/utils/butons_appbar.dart';
import 'package:economy_app/utils/refresh_providers.dart';
import 'package:economy_app/utils/size_screen.dart';
import 'package:economy_app/widgets/drawer_app.dart';
import 'package:economy_app/widgets/widgets_home_screen/global_balance_widget.dart';
import 'package:economy_app/widgets/widgets_home_screen/income_userid_widget.dart';
import 'package:economy_app/widgets/widgets_home_screen/monthly_balance_widget.dart';
import 'package:economy_app/widgets/widgets_home_screen/summary_savings_widget.dart';
import 'package:economy_app/widgets/widgets_home_screen/user_widget.dart';
import 'package:economy_app/widgets/widgets_home_screen/home_sidebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  late String role = '';
  late int userId = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, initialIndex: 0, vsync: this);

    /* 
Esto añade un listener al TabController para mantener sincronizado _selectedIndex con la pestaña activa, pero solo cuando ha terminado el cambio.

addListener: se ejecuta cada vez que cambia algo en el TabController (índice o animación).
_tabController.indexIsChanging == false: significa que la transición ya terminó (no está en proceso de cambio). Así evitamos hacer setState mientras la animación está en curso.
setState(() => _selectedIndex = _tabController.index): actualiza el índice seleccionado al índice actual del TabController (sincroniza, por ejemplo, la sidebar con la pestaña activa).
Por qué se hace así:

Evita múltiples rebuilds durante la animación.
Garantiza que _selectedIndex refleje la pestaña final cuando el usuario desliza o cuando llamas a animateTo.
Si necesitas reaccionar inmediatamente al tap antes de que termine la animación, usa el callback onTap del TabBar o comprueba indexIsChanging==true según el comportamiento deseado.
*/
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    //final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Economy App'),
        backgroundColor: AppColors.primaryColor,
        surfaceTintColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions:
            isDesktop(context)
                ? [
                  ButtonsAppBar('Actualizar datos', onTap: () => refreshProviders(ref)),
                  const SizedBox(width: 20),
                  ButtonsAppBar(
                    'Perfil de usuario',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.USER_PROFILE);
                    },
                  ),
                  const SizedBox(width: 20),
                  ButtonsAppBar(
                    'Todos los ingresos',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.ALL_INCOMES);
                    },
                  ),
                  const SizedBox(width: 20),
                  ButtonsAppBar(
                    'Logout',
                    onTap: () {
                      ref.read(authProvider.notifier).logout();
                      // Actualitzem el userProvider perque com que hem tancat sessió, hem de refrescar l'estat de l'usuari.
                      // Això es fa perque el provider d'usuari depen de l'authProvider, i si aquest canvia, el d'usuari també ha de canviar.
                      ref.invalidate(userProvider);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.LOGIN,
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                ]
                : [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => refreshProviders(ref),
                  ),
                ],
      ),

      drawer: isDesktop(context) ? null : DrawerApp(ref: ref),

      body: userState.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stackTrace) {
          // Per depurar els errors de la API
          //final message = error is ApiError ? error.message : error.toString();
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                // 'Error: $message',
                'Error al cargar los datos. Inténtalo más tarde.',
                style: TextStyle(color: Colors.red, fontSize: 20),
              ),
            ),
          );
        },
        data: (user) {
          if (user == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No se pudo cargar el usuario.',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            );
          }
          // Actualizamos el userId y role
          role = user.role;
          userId = user.id;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.backgroundColor1, AppColors.backgroundColor2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),

            child:
                isTablet(context) ? _buildDesktopLayout(user) : _buildMobileLayout(user),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------------------
  // LAYOUT ESCRITORIO (sidebar + contenido)
  // ----------------------------------------------------------------------
  Widget _buildDesktopLayout(user) {
    return Row(
      children: [
        // SIDEBAR IZQUIERDO
        HomeSidebar(
          userDto: user,
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            setState(() => _selectedIndex = index);
            _tabController.animateTo(index);
          },
        ),

        // CONTENIDO (parte derecha)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: TabBarView(
              controller: _tabController,
              children: [
                Stack(
                  children: [
                    MonthlyBalanceWidget(role: role),
                    role == "ADMIN" || role == "SUPERADMIN"
                        ? Positioned(
                          bottom: 20,
                          right: 20,
                          child: FloatingActionButton(
                            onPressed: () {
                              ref.invalidate(selectedSubcategoryIconProvider);
                              Navigator.pushNamed(context, AppRoutes.NEW_EDIT_CATEGORY);
                            },
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            tooltip: "Agregar nueva categoría",
                            child: const Icon(Icons.add),
                          ),
                        )
                        : SizedBox.shrink(),
                  ],
                ),
                //MonthlyBalanceWidget(role: role),
                IncomeByUseridWidget(role: role),
                SummarySavingsWidget(role: role),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------------
  // LAYOUT MÓVIL (idéntico versión original)
  // ----------------------------------------------------------------------
  Widget _buildMobileLayout(user) {
    return Column(
      children: [
        // HEADER ACTUAL (no se toca)
        Container(
          decoration: BoxDecoration(color: AppColors.primaryColor),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GlobalBalanceWidget(),
                const SizedBox(width: 20),
                UserWidget(userDto: user),
              ],
            ),
          ),
        ),

        // TAB BAR HORIZONTAL (solo móvil)
        Container(
          decoration: const BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white30,
            indicatorColor: Colors.white,
            dividerColor: AppColors.primaryColor,
            labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Movimientos'),
              Tab(text: 'Mis ingresos'),
              Tab(text: 'Ahorros'),
            ],
            padding: const EdgeInsets.only(bottom: 25, top: 10),
          ),
        ),

        // CONTENIDO
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: MonthlyBalanceWidget(role: role),
                  ),
                  role == "ADMIN" || role == "SUPERADMIN"
                      ? Positioned(
                        bottom: 20,
                        right: 20,
                        child: FloatingActionButton(
                          onPressed: () {
                            ref.invalidate(selectedSubcategoryIconProvider);
                            Navigator.pushNamed(context, AppRoutes.NEW_EDIT_CATEGORY);
                          },
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          child: const Icon(Icons.add),
                        ),
                      )
                      : SizedBox.shrink(),
                ],
              ),
              IncomeByUseridWidget(role: role),
              SummarySavingsWidget(role: role),
            ],
          ),
        ),
      ],
    );
  }
}
