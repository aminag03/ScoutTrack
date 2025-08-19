# Document Management System

This document describes the Document management functionality in ScoutTrack.

## Overview

The Document system allows admins to upload, manage, and share documents with troops and members. Only admins can add and delete documents, while troops and members can view and download them.

## Features

- **Admin Functions:**
  - Upload new documents (PDF, DOC, DOCX, TXT, JPG, JPEG, PNG)
  - Set document titles
  - Delete documents
  - View all documents with admin information

- **User Functions (Troops & Members):**
  - View all available documents
  - Search documents by title
  - Download documents

## API Endpoints

### Document Management
- `GET /Document` - Get all documents (with search and pagination)
- `GET /Document/{id}` - Get document by ID
- `POST /Document` - Create new document (Admin only)
- `PUT /Document/{id}` - Update document (Admin only)
- `DELETE /Document/{id}` - Delete document (Admin only)

### File Operations
- `GET /Document/download/{id}` - Download document file
- `POST /Document/upload` - Upload document file (Admin only)

## File Storage

Documents are stored in the `wwwroot/documents/` directory with unique filenames (GUID + extension) to prevent conflicts.

## Security

- Only authenticated users can access documents
- Only users with Admin role can create, update, or delete documents
- File uploads are validated for type and size (max 10MB)
- Allowed file types: PDF, DOC, DOCX, TXT, JPG, JPEG, PNG

## Database Schema

The Document entity includes:
- ID, Title, FilePath
- CreatedAt, UpdatedAt timestamps
- AdminId (foreign key to Admin table)
- Admin navigation property

## Flutter UI

### Admin Screen
- Full CRUD operations
- File upload interface
- Document grid with delete options
- Search functionality

### User Screen (Troops/Members)
- Read-only view
- Document grid
- Download functionality
- Search functionality

## Usage Examples

### Creating a Document
1. Admin selects a file using the file picker
2. Admin enters a title for the document
3. System uploads the file and creates the database record
4. Document becomes available to all users

### Downloading a Document
1. User clicks the download button on a document card
2. System retrieves the file and saves it to the user's device
3. Success message is displayed

## Error Handling

- File type validation
- File size validation
- Duplicate title prevention
- Proper error messages for users
- Exception handling in API and UI

## Future Enhancements

- Document categories/tags
- Version control
- Document approval workflow
- Access control by troop
- Document expiration dates
- Bulk operations
