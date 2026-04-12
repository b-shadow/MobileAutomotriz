import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/features/auth/data/models/usuario_model.dart';
import 'package:mobile1_app/features/user_management/domain/entities/create_user_payload.dart';
import 'package:mobile1_app/features/user_management/domain/entities/managed_user.dart';
import 'package:mobile1_app/features/user_management/domain/entities/role_option.dart';
import 'package:mobile1_app/features/user_management/presentation/cubit/user_management_cubit.dart';
import 'package:mobile1_app/features/user_management/presentation/cubit/user_management_state.dart';
import 'package:mobile1_app/injection_container.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final _searchController = TextEditingController();
  UsuarioModel? _sessionUser;

  bool get _isAdmin => _sessionUser?.isAdmin == true;

  @override
  void initState() {
    super.initState();
    final data = sl<SessionStorage>().userData;
    if (data != null) {
      _sessionUser = UsuarioModel.fromJson(data);
    }
    context.read<UserManagementCubit>().fetchInitial();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserManagementCubit, UserManagementState>(
      listener: (context, state) {
        if (state is UserManagementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(state.message)),
          );
        }
        if (state is UserManagementSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.green, content: Text(state.message)),
          );
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Gestionar Usuarios y Roles',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            bottom: const TabBar(
              indicatorColor: Color(0xFF8B5CF6),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: 'Usuarios'),
                Tab(text: 'Roles'),
              ],
            ),
          ),
          bottomNavigationBar: _isAdmin
              ? SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _showCreateUserDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Crear usuario'),
                      ),
                    ),
                  ),
                )
              : null,
          body: BlocBuilder<UserManagementCubit, UserManagementState>(
            builder: (context, state) {
              if (state is UserManagementInitial || state is UserManagementLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = state is UserManagementLoaded
                  ? state.users
                  : state is UserManagementSuccess
                      ? state.users
                      : state is UserManagementError
                          ? state.users
                          : <ManagedUser>[];

              final roles = state is UserManagementLoaded
                  ? state.roles
                  : state is UserManagementSuccess
                      ? state.roles
                      : state is UserManagementError
                          ? state.roles
                          : <RoleOption>[];

              return TabBarView(
                children: [
                  _buildUsersTab(context, users, roles),
                  _buildRolesTab(roles),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUsersTab(
    BuildContext context,
    List<ManagedUser> users,
    List<RoleOption> roles,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o email...',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.white70),
              onPressed: () {
                context.read<UserManagementCubit>().searchUsers(_searchController.text);
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (users.isEmpty)
          const Text('Sin usuarios.', style: TextStyle(color: Colors.white70))
        else
          ...users.map((user) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _userCard(context, user, roles),
              )),
      ],
    );
  }

  Widget _userCard(BuildContext context, ManagedUser user, List<RoleOption> roles) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(user.fullName, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(user.rolNombre, style: const TextStyle(color: Colors.white)),
              ),
              Text(
                user.activo ? 'Activo' : 'Inactivo',
                style: TextStyle(color: user.activo ? Colors.greenAccent : Colors.redAccent),
              ),
            ],
          ),
          if (_isAdmin) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: roles.any((role) => role.id == user.rolId)
                        ? user.rolId
                        : null,
                    dropdownColor: const Color(0xFF1E293B),
                    decoration: const InputDecoration(
                      labelText: 'Rol',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    items: roles
                        .map(
                          (role) => DropdownMenuItem<String>(
                            value: role.id,
                            child: Text(role.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null && value != user.rolId) {
                        context.read<UserManagementCubit>().changeRole(
                              userId: user.id,
                              roleId: value,
                            );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (user.activo) {
                      context.read<UserManagementCubit>().deactivate(user.id);
                    } else {
                      context.read<UserManagementCubit>().activate(user.id);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        user.activo ? Colors.orange.shade700 : Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(user.activo ? 'Desactivar' : 'Activar'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRolesTab(List<RoleOption> roles) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (roles.isEmpty)
          const Text('Sin roles disponibles.', style: TextStyle(color: Colors.white70))
        else
          ...roles.map(
            (role) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if ((role.descripcion ?? '').isNotEmpty)
                      Text(
                        role.descripcion!,
                        style: const TextStyle(color: Colors.white60),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showCreateUserDialog(BuildContext context) async {
    final nombresController = TextEditingController();
    final apellidosController = TextEditingController();
    final emailController = TextEditingController();
    final passController = TextEditingController();
    final telefonoController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Crear usuario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombresController, decoration: const InputDecoration(labelText: 'Nombres')),
              TextField(controller: apellidosController, decoration: const InputDecoration(labelText: 'Apellidos')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: passController, decoration: const InputDecoration(labelText: 'Password')),
              TextField(controller: telefonoController, decoration: const InputDecoration(labelText: 'Telefono (opcional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nombresController.text.trim().isEmpty ||
                  apellidosController.text.trim().isEmpty ||
                  emailController.text.trim().isEmpty ||
                  passController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('Completa nombres, apellidos, email y password.'),
                  ),
                );
                return;
              }

              Navigator.of(dialogContext).pop();
              context.read<UserManagementCubit>().createUser(
                    CreateUserPayload(
                      nombres: nombresController.text.trim(),
                      apellidos: apellidosController.text.trim(),
                      email: emailController.text.trim(),
                      password: passController.text.trim(),
                      telefono: telefonoController.text.trim(),
                    ),
                  );
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}



