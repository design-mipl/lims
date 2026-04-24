import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
          context.go('/user-management/users/${widget.userId}/permissions');
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
          context.go('/user-management/users/$id/permissions');
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
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormSection(
                  title: 'Basic Details',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppFormFieldRow(
                        children: [
                          AppInput(
                            label: 'Name',
                            controller: _nameCtrl,
                            required: true,
                            errorText: _nameError,
                            size: AppInputSize.sm,
                          ),
                          AppInput(
                            label: 'Email',
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            required: true,
                            errorText: _emailError,
                            size: AppInputSize.sm,
                          ),
                        ],
                      ),
                      SizedBox(height: AppTokens.space3),
                      AppFormFieldRow(
                        children: [
                          AppInput(
                            label: 'Phone',
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            size: AppInputSize.sm,
                          ),
                          AppInput(
                            label: 'Username',
                            controller: _usernameCtrl,
                            required: true,
                            errorText: _usernameError,
                            size: AppInputSize.sm,
                          ),
                        ],
                      ),
                      if (!widget.isEdit) ...[
                        SizedBox(height: AppTokens.space3),
                        AppFormFieldRow(
                          children: [
                            AppInput(
                              label: 'Password',
                              controller: _passwordCtrl,
                              obscureText: true,
                              required: true,
                              errorText: _passwordError,
                              size: AppInputSize.sm,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: AppTokens.space3),
                AppFormSection(
                  title: 'Organization',
                  child: AppFormFieldRow(
                    children: [
                      AppFormFieldSpan(
                        child: AppSelect<String?>(
                          key: ValueKey<String?>(
                            'dept_${_deptId}_${depts.items.length}',
                          ),
                          label: 'Department',
                          value: _deptId != null &&
                                  depts.items.any((d) => d.id == _deptId)
                              ? _deptId
                              : null,
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                'Select department',
                                style: TextStyle(color: AppTokens.hintColor),
                              ),
                            ),
                            ...depts.items.map(
                              (d) => DropdownMenuItem<String?>(
                                value: d.id,
                                child: Text(
                                  d.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _deptId = v),
                          isRequired: true,
                          errorText: _deptError,
                        ),
                      ),
                      AppFormFieldSpan(
                        child: AppSelect<String?>(
                          key: ValueKey<String?>(
                            'role_${_roleId}_${roles.items.length}',
                          ),
                          label: 'Role',
                          value: _roleId != null &&
                                  roles.items.any((r) => r.id == _roleId)
                              ? _roleId
                              : null,
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                'Select role',
                                style: TextStyle(color: AppTokens.hintColor),
                              ),
                            ),
                            ...roles.items.map(
                              (r) => DropdownMenuItem<String?>(
                                value: r.id,
                                child: Text(
                                  r.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _roleId = v),
                          isRequired: true,
                          errorText: _roleError,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppTokens.space3),
                AppFormSection(
                  title: 'Additional',
                  child: AppFormFieldRow(
                    children: [
                      AppInput(
                        label: 'Employee ID',
                        controller: _employeeIdCtrl,
                        size: AppInputSize.sm,
                      ),
                      AppFormFieldSpan(
                        child: AppSelect<UserStatus>(
                          key: ValueKey<UserStatus>(_status),
                          label: 'Status',
                          value: _status,
                          items: UserStatus.values
                              .map(
                                (s) => DropdownMenuItem<UserStatus>(
                                  value: s,
                                  child: Text(s.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _status = v);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
