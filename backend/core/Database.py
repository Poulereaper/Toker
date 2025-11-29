# Database.py
import sqlite3
import json
from typing import Dict, Optional, List
from datetime import datetime
import os

class DatabaseManager:
    """Gestionnaire pour les opérations CRUD sur la base de données"""
    
    def __init__(self, db_path: str = "toker_users.db"):
        """
        Initialise le gestionnaire de base de données
        Args:
            db_path: Chemin vers le fichier de base de données SQLite
        """
        self.db_path = db_path
        self._init_database()
    
    def _init_database(self):
        """Initialise la structure de la base de données si elle n'existe pas"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Ajout de la colonne vector_data pour stocker le profil vectoriel
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                platform TEXT NOT NULL,
                social_user_id TEXT NOT NULL,
                username TEXT NOT NULL,
                user_pseudo TEXT,
                verified BOOLEAN,
                data JSON NOT NULL,
                vector_data JSON,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(platform, social_user_id)
            )
        ''')
        
        conn.commit()
        conn.close()
    
    def create_user(self, platform: str, user_data: Dict, vector_data: Dict = None) -> Dict:
        """
        Crée un nouvel utilisateur dans la base de données
        
        Args:
            platform: Nom de la plateforme sociale
            user_data: Données complètes de l'utilisateur
            vector_data: Données vectorisées (profil d'intérêt) - OPTIONNEL
        
        Returns:
            Dict contenant l'utilisateur créé avec son ID de base de données
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT INTO users (
                    platform, social_user_id, username, user_pseudo, 
                    verified, data, vector_data
                )
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', (
                platform,
                user_data["user_id"],
                user_data["username"],
                user_data.get("user_pseudo", ""),
                user_data.get("verified", False),
                json.dumps(user_data),
                json.dumps(vector_data) if vector_data else None  # Gestion du vecteur
            ))
            
            conn.commit()
            user_id = cursor.lastrowid
            
            # Récupération de l'utilisateur créé
            cursor.execute('SELECT * FROM users WHERE id = ?', (user_id,))
            row = cursor.fetchone()
            
            return self._row_to_dict(row)
            
        finally:
            conn.close()
    
    def get_user(self, user_id: int) -> Optional[Dict]:
        """Récupère un utilisateur par son ID de base de données"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute('SELECT * FROM users WHERE id = ?', (user_id,))
            row = cursor.fetchone()
            
            if row is None:
                return None
            
            return self._row_to_dict(row)
            
        finally:
            conn.close()
    
    def get_all_users(self) -> List[Dict]:
        """Récupère tous les utilisateurs de la base de données"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute('SELECT * FROM users ORDER BY created_at DESC')
            rows = cursor.fetchall()
            
            return [self._row_to_dict(row) for row in rows]
            
        finally:
            conn.close()
    
    def _row_to_dict(self, row) -> Dict:
        """Convertit une ligne SQL en dictionnaire"""
        return {
            "id": row[0],
            "platform": row[1],
            "social_user_id": row[2],
            "username": row[3],
            "user_pseudo": row[4],
            "verified": bool(row[5]),
            "data": json.loads(row[6]),
            "vector_data": json.loads(row[7]) if row[7] else None,  # Récupération du vecteur
            "created_at": row[8],
            "updated_at": row[9]
        }

    def delete_user(self, user_id: int) -> bool:
        """Supprime un utilisateur par son ID"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        try:
            cursor.execute('DELETE FROM users WHERE id = ?', (user_id,))
            conn.commit()
            return cursor.rowcount > 0
        finally:
            conn.close()

    def delete_all_users(self) -> int:
        """Supprime TOUS les utilisateurs de la base"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        try:
            cursor.execute('DELETE FROM users')
            conn.commit()
            return cursor.rowcount
        finally:
            conn.close()

    def update_user(self, user_id: int, user_data: Dict, vector_data: Dict) -> bool:
        """Met à jour les données brutes et le vecteur d'un utilisateur existant"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        try:
            cursor.execute('''
                UPDATE users 
                SET data = ?, vector_data = ?, updated_at = CURRENT_TIMESTAMP
                WHERE id = ?
            ''', (
                json.dumps(user_data),
                json.dumps(vector_data),
                user_id
            ))
            conn.commit()
            return cursor.rowcount > 0
        finally:
            conn.close()