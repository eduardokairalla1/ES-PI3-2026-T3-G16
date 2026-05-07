/**
 * Startup types and schema.
 *
 * Eduardo Kairalla - 24024241
 */


/**
 * TYPES
 */

export type StartupStage = 'new' | 'operating' | 'expanding';

export interface PartnerDocument
{
    avatar_url: string | null;
    bio: string | null;
    equity_pct: number;
    name: string;
    role: string;
}

export interface AdvisorDocument
{
    name: string;
    role: string;
}

export interface StartupDocument
{
    advisors: AdvisorDocument[];
    capital_raised: number;
    created_at: Date;
    description: string;
    executive_summary: string;
    id: string;
    logo_url: string;
    name: string;
    partners: PartnerDocument[];
    stage: StartupStage;
    tagline: string;
    token_price: number;
    total_tokens: number;
    updated_at: Date | null;
    video_url: string | null;
}

export interface QuestionDocument
{
    answer: string | null;
    answered_at: Date | null;
    author_name: string;
    author_uid: string;
    created_at: Date;
    id: string;
    is_private: boolean;
    startup_id: string;
    text: string;
}
