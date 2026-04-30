import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../departments/state/departments_provider.dart';
import '../../roles/state/roles_provider.dart';
import '../data/user_model.dart';
import '../state/users_provider.dart';

/// Create or edit user (full-page form). [userId] null = create.
class UserFormPage extends StatefulWidget {
  const UserFormPage({super.key, this.userId});

  final String? userId;

  bool get isEdit => userId != null;

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _employeeIdCtrl = TextEditingController();

  String? _deptId;
  String? _roleId;
  UserStatus _status = UserStatus.active;

  bool _prefilled = false;
  String? _nameError;
  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _deptError;
  String? _roleError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _employeeIdCtrl.dispose();
    super.dispose();
  }

  void _prefillFrom(UserModel u) {
    _nameCtrl.text = u.name;
    _emailCtrl.text = u.email;
    _phoneCtrl.text = u.phone ?? '';
    _usernameCtrl.text = u.username;
    _employeeIdCtrl.text = u.employeeId ?? '';
    _deptId = u.departmentId;
    _roleId = u.roleId;
    _status = u.status;
  }

  bool _validate() {
    var ok = true;
    _nameError = null;
    _emailError = null;
    _usernameError = null;
    _passwordError = null;
    _deptError = null;
    _roleError = null;

    if (_nameCtrl.text.trim().isEmpty) {
      _nameError = 'Required';
      ok = false;
    }
    if (_emailCtrl.text.trim().isEmpty) {
      _emailError = 'Required';
      ok = false;
    }
    if (_usernameCtrl.text.trim().isEmpty) {
      _usernameError = 'Required';
      ok = false;
    }
    if (!widget.isEdit && _passwordCtrl.text.isEmpty) {
      _passwordError = 'Required';
      ok = false;
    }
    if (_deptId == null || _deptId!.isEmpty) {
      _deptError = 'Required';
      ok = false;
    }
    if (_roleId == null || _roleId!.isEmpty) {
      _roleError = 'Required';
      ok = false;
    }
    setState(() {});
    return ok;
  }

  String? _deptName(DepartmentsProvider d) {
    if (_deptId == null) {
      return null;
    }
    for (final x in d.items) {
      if (x.id == _deptId) {
        return x.name;
      }
    }
    return null;
  }

  String? _roleName(RolesProvider r) {
    if (_roleId == null) {
      return null;
    }
    for (final x in r.items) {
      if (x.id == _roleId) {
        return x.name;
      }
    }
    return null;
  }

  Future<void> _onSave(BuildContext context) async {
    if (!_validate()) {
      return;
    }
    final users = context.read<UsersProvider>();
    final depts = context.read<DepartmentsProvider>();
    final roles = context.read<RolesProvider>();
    final deptName = _deptName(depts);
    final roleName = _roleName(roles);
    if (deptName == null || roleName == null) {
      return;
    }

    final phone = _phoneCtrl.text.trim();
    final emp = _employeeIdCtrl.text.trim();

    if (widget.isEdit) {
      await users.updateUser(
        id: widget.userId!,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: phone.isEmpty ? null : phone,
        username: _usernameCtrl.text.trim(),
        employeeId: emp.isEmpty ? null : emp,
        departmentId: _deptId!,
        departmentName: deptName,
        roleId: _roleId!,
        roleName: roleName,
        status: _status,
      );
      if (context.mounted) {
        if (users.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(users.error ?? 'Save failed')),
          );
        } else {
          final roleLabel = roleName;
          context.push(
            '/user-management/users/${widget.userId}/permissions',
            extra: <String, dynamic>{
              'name': _nameCtrl.text.trim(),
              'role': roleLabel,
              'isAdmin': roleLabel == 'Admin',
            },
          );
        }
      }
    } else {
      final id = await users.createUser(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: phone.isEmpty ? null : phone,
        username: _usernameCtrl.text.trim(),
        employeeId: emp.isEmpty ? null : emp,
        departmentId: _deptId!,
        departmentName: deptName,
        roleId: _roleId!,
        roleName: roleName,
        status: _status,
      );
      if (context.mounted) {
        if (users.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(users.error ?? 'Save failed')),
          );
        } else if (id != null) {
          final roleLabel = roleName;
          context.push(
            '/user-management/users/$id/permissions',
            extra: <String, dynamic>{
              'name': _nameCtrl.text.trim(),
              'role': roleLabel,
              'isAdmin': roleLabel == 'Admin',
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final users = context.watch<UsersProvider>();
    final depts = context.watch<DepartmentsProvider>();
    final roles = context.watch<RolesProvider>();

    if (widget.isEdit && !users.isLoading && !_prefilled) {
      final u = users.userById(widget.userId!);
      if (u != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_prefilled) {
            setState(() {
              _prefillFrom(u);
              _prefilled = true;
            });
          }
        });
      }
    }

    final notFound =
        widget.isEdit && !users.isLoading && users.userById(widget.userId!) == null;

    void back() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/user-management/users');
      }
    }

    return AppFormPage(
      title: widget.isEdit ? 'Edit User' : 'Create User',
      subtitle: widget.isEdit
          ? 'Update profile and organization'
          : 'Add a new account',
      onBack: back,
      cancelLabel: 'Cancel',
      onCancel: back,
      primaryLabel: 'Save & Continue to Permissions',
      onPrimary: notFound ? null : () => _onSave(context),
      isPrimaryLoading: users.isLoading,
      primaryEnabled: !notFound,
      body: notFound
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(AppTokens.space6),
                child: Text(
                  'User not found.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : AppFormPageLayout(
              left: AppFormPageLayout.sectionsColumn([
                AppFormSection(
                  title: 'Basic Details',
                  children: [
                    AppInput(
                      label: 'Full Name',
                      hint: 'Enter full name',
                      controller: _nameCtrl,
                      isRequired: true,
                      errorText: _nameError,
                      onChanged: (_) {
                        if (_nameError != null) {
                          setState(() => _nameError = null);
                        }
                      },
                    ),
                    AppInput(
                      label: 'Email',
                      hint: 'Enter email address',
                      controller: _emailCtrl,
                      prefixIcon: Icon(LucideIcons.mail),
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                      errorText: _emailError,
                      onChanged: (_) {
                        if (_emailError != null) {
                          setState(() => _emailError = null);
                        }
                      },
                    ),
                    AppInput(
                      label: 'Phone',
                      hint: 'Enter phone number',
                      controller: _phoneCtrl,
                      prefixIcon: Icon(LucideIcons.phone),
                      keyboardType: TextInputType.phone,
                    ),
                    AppInput(
                      label: 'Username',
                      hint: 'Enter username',
                      controller: _usernameCtrl,
                      isRequired: true,
                      errorText: _usernameError,
                      onChanged: (_) {
                        if (_usernameError != null) {
                          setState(() => _usernameError = null);
                        }
                      },
                    ),
                    AppFormFullWidth(
                      child: AppInput(
                        label: 'Password',
                        hint: 'Enter password',
                        obscureText: true,
                        controller: _passwordCtrl,
                        isRequired: !widget.isEdit,
                        errorText: _passwordError,
                        onChanged: (_) {
                          if (_passwordError != null) {
                            setState(() => _passwordError = null);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ]),
              right: AppFormPageLayout.sectionsColumn([
                AppFormSection(
                  title: 'Organisation',
                  children: [
                    AppSelect<String?>(
                      key: ValueKey<String?>(
                        'dept_${_deptId}_${depts.items.length}',
                      ),
                      label: 'Department',
                      hint: 'Select department',
                      value: _deptId != null &&
                              depts.items.any((d) => d.id == _deptId)
                          ? _deptId
                          : null,
                      items: [
                        const AppSelectItem<String?>(
                          value: null,
                          label: 'Select department',
                        ),
                        ...depts.items.map(
                          (d) => AppSelectItem<String?>(
                            value: d.id,
                            label: d.name,
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _deptId = v),
                      isRequired: true,
                      errorText: _deptError,
                    ),
                    AppSelect<String?>(
                      key: ValueKey<String?>(
                        'role_${_roleId}_${roles.items.length}',
                      ),
                      label: 'Role',
                      hint: 'Select role',
                      value: _roleId != null &&
                              roles.items.any((r) => r.id == _roleId)
                          ? _roleId
                          : null,
                      items: [
                        const AppSelectItem<String?>(
                          value: null,
                          label: 'Select role',
                        ),
                        ...roles.items.map(
                          (r) => AppSelectItem<String?>(
                            value: r.id,
                            label: r.name,
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _roleId = v),
                      isRequired: true,
                      errorText: _roleError,
                    ),
                  ],
                ),
                AppFormSection(
                  title: 'Additional',
                  children: [
                    AppInput(
                      label: 'Employee ID',
                      hint: 'Enter employee ID',
                      controller: _employeeIdCtrl,
                    ),
                    AppFormFullWidth(
                      child: AppSegmentedControl(
                        label: 'Status',
                        options: const [
                          AppSegmentOption(
                            value: 'active',
                            label: 'Active',
                            icon: LucideIcons.check,
                          ),
                          AppSegmentOption(
                            value: 'inactive',
                            label: 'Inactive',
                            icon: LucideIcons.ban,
                          ),
                        ],
                        value: _status.name,
                        onChanged: (v) => setState(
                          () => _status = UserStatus.values
                              .firstWhere((s) => s.name == v),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
    );
  }
}
