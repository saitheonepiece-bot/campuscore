// Database Operations Module
class Database {
    constructor() {
        this.client = null;
    }

    init() {
        this.client = window.supabaseClient.getClient();
    }

    // Generic CRUD operations
    async query(table, options = {}) {
        try {
            let query = this.client.from(table).select(options.select || '*');

            if (options.filters) {
                Object.entries(options.filters).forEach(([key, value]) => {
                    query = query.eq(key, value);
                });
            }

            if (options.order) {
                query = query.order(options.order.column, { ascending: options.order.ascending !== false });
            }

            if (options.limit) {
                query = query.limit(options.limit);
            }

            const { data, error } = await query;

            if (error) throw error;
            return data;
        } catch (error) {
            console.error(`Query error on ${table}:`, error);
            throw error;
        }
    }

    async insert(table, data) {
        try {
            const { data: result, error } = await this.client
                .from(table)
                .insert(data)
                .select();

            if (error) throw error;
            return result;
        } catch (error) {
            console.error(`Insert error on ${table}:`, error);
            throw error;
        }
    }

    async update(table, id, data) {
        try {
            const { data: result, error } = await this.client
                .from(table)
                .update(data)
                .eq('id', id)
                .select();

            if (error) throw error;
            return result;
        } catch (error) {
            console.error(`Update error on ${table}:`, error);
            throw error;
        }
    }

    async delete(table, id) {
        try {
            const { error } = await this.client
                .from(table)
                .delete()
                .eq('id', id);

            if (error) throw error;
            return true;
        } catch (error) {
            console.error(`Delete error on ${table}:`, error);
            throw error;
        }
    }

    // Specific queries for the application
    async getStudents(filters = {}) {
        return await this.query('students', { filters });
    }

    async getParents(filters = {}) {
        return await this.query('parents', { filters });
    }

    async getTeachers(filters = {}) {
        return await this.query('teachers', { filters });
    }

    async getAttendance(studentId = null) {
        const filters = studentId ? { studentId } : {};
        return await this.query('attendance', {
            filters,
            order: { column: 'date', ascending: false }
        });
    }

    async markAttendance(attendanceData) {
        return await this.insert('attendance', attendanceData);
    }

    async getHomework(filters = {}) {
        return await this.query('homework', {
            filters,
            order: { column: 'date', ascending: false }
        });
    }

    async addHomework(homeworkData) {
        return await this.insert('homework', homeworkData);
    }

    async getExamSchedules(filters = {}) {
        return await this.query('exam_schedules', {
            filters,
            order: { column: 'date', ascending: true }
        });
    }

    async getExamResults(filters = {}) {
        return await this.query('exam_results', { filters });
    }

    async addExamResult(resultData) {
        return await this.insert('exam_results', resultData);
    }

    async getTimetables(className = null) {
        const filters = className ? { class: className } : {};
        return await this.query('timetables', { filters });
    }

    async getIssues(filters = {}) {
        return await this.query('issues', {
            filters,
            order: { column: 'created_at', ascending: false }
        });
    }

    async addIssue(issueData) {
        return await this.insert('issues', issueData);
    }

    async updateIssue(id, updates) {
        return await this.update('issues', id, updates);
    }

    async getHolidays() {
        return await this.query('holidays', {
            order: { column: 'date', ascending: true }
        });
    }

    async getReportCards(filters = {}) {
        return await this.query('report_cards', { filters });
    }

    async getClasses() {
        return await this.query('classes');
    }

    async getCoordinators(filters = {}) {
        return await this.query('coordinators', { filters });
    }

    async getVicePrincipals(filters = {}) {
        return await this.query('vice_principals', { filters });
    }

    async getSuperVicePrincipals(filters = {}) {
        return await this.query('super_vice_principals', { filters });
    }

    async getClassTeachers(filters = {}) {
        return await this.query('class_teachers', { filters });
    }

    async getTeacherDuties(teacherId = null) {
        const filters = teacherId ? { teacher_id: teacherId } : {};
        return await this.query('teacher_duties', { filters });
    }

    async assignDuty(dutyData) {
        return await this.insert('teacher_duties', dutyData);
    }
}

// Create singleton instance
const database = new Database();
window.database = database;
