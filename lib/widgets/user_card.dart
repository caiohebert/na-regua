import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String? name;
  final String? email;
  final String? role;
  final String? avatarUrl;
  final Widget? trailing;

  const UserCard({
    super.key,
    this.name,
    this.email,
    this.role,
    this.avatarUrl,
    this.trailing,
  });

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: hasImage ? NetworkImage(avatarUrl!) : null,
          child: !hasImage ? Text(_initials(name)) : null,
        ),
        title: Text(name ?? 'Usuário sem nome'),
        subtitle: Text(email ?? ''),
        trailing: trailing,
      ),
    );
  }
}
