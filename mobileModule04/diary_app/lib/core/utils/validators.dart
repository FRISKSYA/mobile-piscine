class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }
  
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    
    return null;
  }
  
  static String? validateContent(String? value) {
    if (value == null || value.isEmpty) {
      return 'Content is required';
    }
    
    if (value.length > 5000) {
      return 'Content must be less than 5000 characters';
    }
    
    return null;
  }
  
  static String? validateMood(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a mood';
    }
    
    return null;
  }
}